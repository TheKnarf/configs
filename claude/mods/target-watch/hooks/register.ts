import type { EngineInterface, Register } from 'claude-code'

// Watches the `target/` folder in whatever directory an agent works in and,
// when it grows past the limit, adds a note to that agent's next tool result.
// Silent otherwise. Uses only `du`/`df` (macOS, Linux) or the mod's own file
// API plus PowerShell's DriveInfo (Windows): no cargo, no Node.

const GB = 1024 ** 3
const MAX_LIMIT = 100 * GB // the usual ceiling
const FREE_SHARE = 0.5 // ...lowered to this share of the disk's free space
const MIN_LIMIT = 1 * GB // ...but never below this
const REWARN_GROWTH = 1.2 // warn again once it grew 20% past the last warning
const STALE_AFTER_BASH_MS = 2 * 60_000 // re-measure soon after shell commands
const STALE_MS = 10 * 60_000 // and now and then otherwise
const STAT_FRESH_MS = 60_000 // how long "is there a target/ here" is trusted
const WALK_CONCURRENCY = 16
const ACTIVE = new Set(['pending', 'running', 'waiting'])

type Reading = { bytes: number; free: number | null; at: number }
type Watch = {
  reading?: Reading
  isMeasuring?: boolean
  warnedAtBytes?: number
  isDir?: boolean
  checkedAt?: number
}

const watches = new Map<string, Watch>()
let mainCwd: string | undefined
let platform: string | undefined

const join = (dir: string, name: string) => {
  const sep = dir.includes('\\') && !dir.includes('/') ? '\\' : '/'
  return dir.endsWith(sep) ? dir + name : dir + sep + name
}

const fmt = (bytes: number) => {
  const gb = bytes / GB
  return `${gb < 10 ? gb.toFixed(1) : Math.round(gb)} GB`
}

const limitFor = (free: number | null) =>
  free === null ? MAX_LIMIT : Math.min(MAX_LIMIT, Math.max(MIN_LIMIT, free * FREE_SHARE))

async function getPlatform($: EngineInterface) {
  platform ??= (await $.session.info()).platform ?? 'unknown'
  return platform
}

// Sum of file sizes under `root`, through the mod's file API (any OS).
async function walkSize($: EngineInterface, root: string) {
  let total = 0
  let active = 0
  const queue = [root]
  await new Promise<void>(resolve => {
    const pump = () => {
      if (queue.length === 0 && active === 0) return resolve()
      while (active < WALK_CONCURRENCY && queue.length > 0) {
        const dir = queue.pop()!
        active++
        $.fs
          .list(dir)
          .then(
            entries => {
              for (const entry of entries) {
                if (entry.isLink) continue
                if (entry.kind === 'file') total += entry.size
                else if (entry.kind === 'dir') queue.push(join(dir, entry.name))
              }
            },
            () => {},
          )
          .finally(() => {
            active--
            pump()
          })
      }
    }
    pump()
  })
  return total
}

async function unixSize($: EngineInterface, path: string) {
  const { stdout } = await $.process.run(['du', '-sk', path], { timeoutMs: 600_000 })
  const kb = parseInt(stdout, 10) // du may exit non-zero on unreadable files but still totals
  return Number.isFinite(kb) ? kb * 1024 : walkSize($, path)
}

async function unixFree($: EngineInterface, path: string) {
  const { stdout } = await $.process.run(['df', '-kP', path])
  // Filesystem 1024-blocks Used Available Capacity Mounted-on (names may hold spaces)
  const m = stdout.split('\n')[1]?.match(/\s(\d+)\s+(\d+)\s+(\d+)\s+\d+%\s/)
  return m ? Number(m[3]) * 1024 : null
}

async function windowsFree($: EngineInterface, path: string) {
  const { exitCode, stdout } = await $.process.run(
    [
      'powershell',
      '-NoProfile',
      '-NonInteractive',
      '-Command',
      '[System.IO.DriveInfo]::new([System.IO.Path]::GetPathRoot($env:TARGET_WATCH_PATH)).AvailableFreeSpace',
    ],
    { env: { TARGET_WATCH_PATH: path } },
  )
  const bytes = Number(stdout.trim())
  return exitCode === 0 && Number.isFinite(bytes) ? bytes : null
}

async function measure($: EngineInterface, path: string, watch: Watch) {
  if (watch.isMeasuring) return
  watch.isMeasuring = true
  try {
    const isWindows = (await getPlatform($)) === 'windows'
    const [bytes, free] = await Promise.all([
      isWindows ? walkSize($, path) : unixSize($, path),
      (isWindows ? windowsFree($, path) : unixFree($, path)).catch(() => null),
    ])
    watch.reading = { bytes, free, at: await $.clock.now() }
  } catch (err) {
    $.ui.log(`target-watch: measuring ${path} failed: ${String(err)}`, { to: 'debug' })
  } finally {
    watch.isMeasuring = false
  }
}

async function hasTargetDir($: EngineInterface, path: string, watch: Watch, now: number) {
  if (watch.checkedAt !== undefined && now - watch.checkedAt < STAT_FRESH_MS) return watch.isDir
  try {
    watch.isDir = (await $.fs.stat(path)).kind === 'dir'
  } catch {
    watch.isDir = false
  }
  watch.checkedAt = now
  if (!watch.isDir) {
    watch.reading = undefined
    watch.warnedAtBytes = undefined
  }
  return watch.isDir
}

// Only the one agent working in a target/ is told about it: never while another
// active agent shares it, and a subagent sharing the main chat's folder leaves
// the decision to the main chat (told once its subagents there are done).
async function mayTell($: EngineInterface, agentId: string | undefined, target: string) {
  const others = (await $.agent.list()).filter(a => a.id !== agentId && ACTIVE.has(a.status))
  if (others.some(a => join(a.cwd, 'target') === target)) return false
  if (agentId !== undefined) {
    const main = mainCwd ?? (await $.session.root())
    if (join(main, 'target') === target) return false
  }
  return true
}

function message(target: string, reading: Reading, limit: number) {
  const free = reading.free === null ? 'free space unknown' : `${fmt(reading.free)} free on this disk`
  const lowered = limit < MAX_LIMIT ? `, lowered from ${fmt(MAX_LIMIT)} because free disk space is low` : ''
  return (
    `target-watch: ${target} is ${fmt(reading.bytes)}, over the ${fmt(limit)} limit` +
    `${lowered} (${free}). Consider running \`cargo clean\` (or otherwise clearing it) ` +
    `when no build is running there. No other active agent works in this folder.`
  )
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    mainCwd = e.cwd
    return next(e)
  })

  on('tool.call', async ($, e, next) => {
    const ran = await next(e)
    if (ran.deny !== undefined) return ran
    try {
      const cwd = await $.session.cwd() // the calling agent's own (its worktree, if any)
      if (e.agentId === undefined) mainCwd = cwd
      const target = join(cwd, 'target')
      const now = await $.clock.now()
      let watch = watches.get(target)
      if (!watch) watches.set(target, (watch = {}))

      const dbg = (msg: string) => $.ui.log(`target-watch: [${e.agentId ?? 'main'} ${String(e.tool)}] ${target}: ${msg}`, { to: 'debug' })
      if (!(await hasTargetDir($, target, watch, now))) return dbg('no target dir'), ran

      const staleMs = ['Bash', 'PowerShell'].includes(String(e.tool)) ? STALE_AFTER_BASH_MS : STALE_MS
      if (!watch.reading || now - watch.reading.at > staleMs) void measure($, target, watch)

      const reading = watch.reading
      if (!reading) return dbg('no reading yet'), ran
      const limit = limitFor(reading.free)
      dbg(`${fmt(reading.bytes)} of ${fmt(limit)} limit, ${reading.free === null ? '?' : fmt(reading.free)} free, read ${Math.round((now - reading.at) / 1000)}s ago`)
      if (reading.bytes < limit) {
        watch.warnedAtBytes = undefined
        return ran
      }
      if (watch.warnedAtBytes !== undefined && reading.bytes < watch.warnedAtBytes * REWARN_GROWTH) return ran
      if (!(await mayTell($, e.agentId, target))) return dbg(`deferred, agents: ${JSON.stringify((await $.agent.list()).map(a => [a.id, a.status, a.cwd]))}`), ran
      dbg('warning')

      watch.warnedAtBytes = reading.bytes
      return { ...ran, context: [...(ran.context ?? []), message(target, reading, limit)] }
    } catch (err) {
      $.ui.log(`target-watch: ${String(err)}`, { to: 'debug' })
      return ran
    }
    // Never stand in a tool call's way: if this hook fails, the call goes on as usual.
  }).catch(($, e, next) => next(e))
}
