import { expect, test } from 'claude-code/testing'

const GB = 1024 ** 3

type World = {
  cwd: string
  sizes: Record<string, number> // target path -> bytes
  free: number
  agents: { id: string; cwd: string; status: string }[]
}

// Stands for the engine and the OS beneath the mod: a fake disk, `du`, `df`
// and agent list. Each test uses its own paths.
function engine(on: any, world: World) {
  on('session.info', () => ({ value: { transcriptPath: '', platform: 'macos' } }))
  on('session.cwd', () => ({ value: world.cwd }))
  on('session.root', () => ({ value: '/' }))
  on('clock.now', () => ({ value: Date.now() }))
  on('agent.list', () => ({ value: world.agents }))
  on('fs.stat', (_: unknown, e: { path: string }) =>
    e.path in world.sizes
      ? { value: { kind: 'dir', size: 0, mtimeMs: 0, isLink: false } }
      : { deny: 'ENOENT' },
  )
  on('process.run', (_: unknown, e: { argv: string[] }) => {
    const [cmd, , path] = e.argv
    if (cmd === 'du') return { value: { exitCode: 0, stdout: `${Math.round(world.sizes[path!]! / 1024)}\t${path}\n`, stderr: '', isStdoutTruncated: false, isStderrTruncated: false } }
    if (cmd === 'df') {
      const kb = Math.round(world.free / 1024)
      return { value: { exitCode: 0, stdout: `Filesystem 1024-blocks Used Available Capacity Mounted on\n/dev/disk3s5 999999999 1 ${kb} 50% /System/Volumes/Data\n`, stderr: '', isStdoutTruncated: false, isStderrTruncated: false } }
    }
    return { value: { exitCode: 1, stdout: '', stderr: 'unexpected', isStdoutTruncated: false, isStderrTruncated: false } }
  })
  on('tool.call', () => ({ result: {} }))
}

// The first call starts a measurement in the background; later calls read it.
async function calls($: any, n: number, extra: object = {}) {
  const out: (readonly string[] | undefined)[] = []
  for (let i = 0; i < n; i++) out.push((await $.tool.call({ tool: 'Bash', command: 'cargo build', ...extra })).context)
  return out
}
const warned = (ctx: readonly string[] | undefined) => (ctx ?? []).some(c => c.startsWith('target-watch:'))

test('the main chat is told once when its target/ passes 100 GB', async ($, on) => {
  engine(on, { cwd: '/a', sizes: { '/a/target': 120 * GB }, free: 500 * GB, agents: [] })
  const ctx = await calls($, 4)
  expect(ctx.filter(warned).length).toBe(1)
  expect(ctx.find(warned)!.join('')).toContain('/a/target is 120 GB, over the 100 GB limit')
})

test('a small target/ and a missing one stay silent', async ($, on) => {
  const world = { cwd: '/b', sizes: { '/b/target': 30 * GB }, free: 500 * GB, agents: [] }
  engine(on, world)
  expect((await calls($, 3)).some(warned)).toBe(false)
  world.cwd = '/b2' // no target/ there
  expect((await calls($, 3)).some(warned)).toBe(false)
})

test('low free space lowers the limit', async ($, on) => {
  engine(on, { cwd: '/c', sizes: { '/c/target': 30 * GB }, free: 40 * GB, agents: [] })
  const ctx = await calls($, 3)
  expect(ctx.find(warned)!.join('')).toContain('over the 20 GB limit, lowered from 100 GB')
})

test('the main chat waits while a subagent works in the same folder', async ($, on) => {
  const world = { cwd: '/d', sizes: { '/d/target': 120 * GB }, free: 500 * GB, agents: [{ id: 'sub1', cwd: '/d', status: 'running' }] }
  engine(on, world)
  expect((await calls($, 3)).some(warned)).toBe(false) // main
  expect((await calls($, 3, { agentId: 'sub1' })).some(warned)).toBe(false) // the subagent shares main's folder
  world.agents = [{ id: 'sub1', cwd: '/d', status: 'completed' }]
  expect((await calls($, 2)).some(warned)).toBe(true) // main, once the subagent is done
})

test('a subagent in its own worktree is told about its own target/', async ($, on) => {
  const world = { cwd: '/e', sizes: { '/e/target': 1 * GB, '/e/.wt/x/target': 120 * GB }, free: 500 * GB, agents: [{ id: 'wt1', cwd: '/e/.wt/x', status: 'running' }] }
  engine(on, world)
  expect((await calls($, 2)).some(warned)).toBe(false) // main's own target/ is small
  world.cwd = '/e/.wt/x'
  const sub = await calls($, 3, { agentId: 'wt1' })
  expect(sub.find(warned)!.join('')).toContain('/e/.wt/x/target is 120 GB')
})
