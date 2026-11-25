import { expect, test } from 'claude-code/testing'

import { colorFor, PALETTE } from '../hooks/register.tsx'

const NOW = Date.parse('2026-11-25T09:00:00Z')
const H = 3_600_000

type Setup = { rateLimits?: unknown[]; env?: Record<string, string>; files?: Record<string, unknown> }

function engine(on: any, { rateLimits = [], env = { HOME: '/home/me' }, files = {} }: Setup) {
  const read: string[] = []
  on('clock.now', () => ({ value: NOW }))
  on('clock.every', () => ({ value: { cancel() {} } }))
  on('ui.invalidate', () => ({ value: undefined }))
  on('env.get', (_: unknown, e: { name: string }) => ({ value: env[e.name] }))
  on('fs.read', (_: unknown, e: { path: string }) => {
    read.push(e.path)
    return e.path in files ? { value: JSON.stringify(files[e.path]) } : { deny: 'ENOENT' }
  })
  on('session.usage', () => ({ value: { startedAt: NOW, context: {}, rateLimits } }))
  on('session.start', (_: unknown, e: { cwd: string }) => ({ cwd: e.cwd }))
  on('session.measure', (_: unknown, e: { changed: string[] }) => ({ changed: e.changed }))
  return { read }
}

const start = ($: any) => $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })

const BAND = {
  plugin: 'account-usage',
  component: 'AbovePrompt',
  props: {
    hasSurvey: false,
    isCollapsed: false,
    isWorking: false,
    maxRows: 5,
    bodyColumns: 100,
    scroll: { offset: 0, bodyRows: 5 },
    view: {},
  },
} as const

const personal = { oauthAccount: { emailAddress: 'me@home.example', organizationName: "me@home.example's Organization", organizationType: 'claude_max' } }
const corp = { oauthAccount: { emailAddress: 'me@corp.example', organizationName: 'Corp', organizationType: 'claude_team' } }
const week = (percentUsed: number, inMs: number) => ({ kind: 'seven_day', percentUsed, resetsAt: new Date(NOW + inMs).toISOString() })

test('an email always gets the same palette color, and case does not matter', () => {
  expect(PALETTE).toContain(colorFor('me@home.example'))
  expect(colorFor('Me@Home.Example ')).toBe(colorFor('me@home.example'))
  // The two test accounts land on different colors, as a work and a personal account should.
  expect(colorFor('me@corp.example')).not.toBe(colorFor('me@home.example'))
})

for (const surface of ['terminal', 'desktop'] as const) {
  test(`draws the account badge in its color and the weekly usage (${surface})`, async ($, on) => {
    engine(on, { rateLimits: [{ kind: 'five_hour', percentUsed: 80 }, week(37.4, 52 * H)], files: { '/home/me/.claude.json': personal } })
    await start($)
    const ui = await $.ui.mount({ ...BAND, surface })
    const badge = await ui.find({ type: 'Text', text: /me@home\.example/ })
    expect(badge?.text).toBe(' me@home.example ')
    expect(badge?.props.backgroundColor).toBe(colorFor('me@home.example'))
    expect((await ui.find({ type: 'Text', text: /Week/ }))?.text).toBe('  Week: 63% left · resets in 2d 4h')
    await ui.unmount()
  })
}

test('reads the login record from CLAUDE_CONFIG_DIR and names a team organization', async ($, on) => {
  const { read } = engine(on, {
    env: { HOME: '/home/me', CLAUDE_CONFIG_DIR: '/home/me/.claude-work/' },
    files: { '/home/me/.claude.json': personal, '/home/me/.claude-work/.claude.json': corp },
  })
  await start($)
  expect(read).toEqual(['/home/me/.claude-work/.claude.json'])
  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  const badge = await ui.find({ type: 'Text', text: /corp/ })
  expect(badge?.text).toBe(' me@corp.example (Corp) ')
  expect(badge?.props.backgroundColor).toBe(colorFor('me@corp.example'))
  await ui.unmount()
})

test('follows the engine as the window moves', async ($, on) => {
  engine(on, { files: { '/home/me/.claude.json': personal } })
  await start($)
  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect(await ui.find({ type: 'Text', text: /Week/ })).toBeUndefined() // no usage reading yet
  await $.session.measure({ context: {}, rateLimits: [week(100, 90 * 60_000)], changed: ['rateLimits'] })
  await ui.unmount()
  const again = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect((await again.find({ type: 'Text', text: /Week/ }))?.text).toBe('  Week: limit reached · resets in 1h 30m')
  await again.unmount()
})

test('draws nothing with no login record and no weekly window (API key)', async ($, on) => {
  engine(on, { rateLimits: [{ kind: 'spend_limit', percentUsed: 10 }] })
  on('ui.render', ($: any, e: any) => {
    const { Text } = $.ui.resolve(e)
    return <Text>engine</Text>
  })
  await start($)
  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect((await ui.find({ type: 'Text' }))?.text).toBe('engine')
  await ui.unmount()
})
