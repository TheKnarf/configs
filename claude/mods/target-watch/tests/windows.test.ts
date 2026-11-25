import { expect, test } from 'claude-code/testing'

const GB = 1024 ** 3

// The first call starts a measurement in the background; later calls read it.
async function calls($: any, n: number, extra: object = {}) {
  const out: (readonly string[] | undefined)[] = []
  for (let i = 0; i < n; i++) out.push((await $.tool.call({ tool: 'Bash', command: 'cargo build', ...extra })).context)
  return out
}
const warned = (ctx: readonly string[] | undefined) => (ctx ?? []).some(c => c.startsWith('target-watch:'))

test('on Windows it sums the folder through the file API and asks PowerShell for free space', async ($, on) => {
  on('session.info', () => ({ value: { transcriptPath: '', platform: 'windows' } }))
  on('session.cwd', () => ({ value: 'C:\\w' }))
  on('session.root', () => ({ value: 'C:\\' }))
  on('clock.now', () => ({ value: Date.now() }))
  on('agent.list', () => ({ value: [] }))
  on('fs.stat', () => ({ value: { kind: 'dir', size: 0, mtimeMs: 0, isLink: false } }))
  const tree: Record<string, { name: string; kind: string; size: number; mtimeMs: number; isLink: boolean }[]> = {
    'C:\\w\\target': [
      { name: 'debug', kind: 'dir', size: 0, mtimeMs: 0, isLink: false },
      { name: 'big.rlib', kind: 'file', size: 70 * GB, mtimeMs: 0, isLink: false },
    ],
    'C:\\w\\target\\debug': [{ name: 'deps.bin', kind: 'file', size: 50 * GB, mtimeMs: 0, isLink: false }],
  }
  on('fs.list', (_: unknown, e: { path: string }) => ({ value: tree[e.path.slice(e.path.indexOf('C:'))] ?? [] }))
  on('process.run', (_: unknown, e: { argv: string[] }) => ({
    value: { exitCode: e.argv[0] === 'powershell' ? 0 : 1, stdout: `${500 * GB}\r\n`, stderr: '', isStdoutTruncated: false, isStderrTruncated: false },
  }))
  on('tool.call', () => ({ result: {} }))
  // The runner is not Windows, so it reads C:\ paths as relative: the fake disk keys on the C: part.
  const logs: unknown[] = []
  on('ui.log', (_: unknown, e: unknown) => (logs.push(e), { value: undefined }))
  const ctx = await calls($, 3)
  expect(logs.filter(l => JSON.stringify(l).includes('failed'))).toEqual([])
  expect(ctx.find(warned)!.join('')).toContain('C:\\w\\target is 120 GB, over the 100 GB limit (500 GB free on this disk)')
})
