import type { EngineInterface, Register, SessionRateLimit } from 'claude-code'

// A row above the prompt with the signed-in account and its weekly usage:
//   [ me@example.com ]  Week: 63% left · resets in 2d 4h
// The account badge's color comes from a hash of the email, so each account
// keeps its own color and a different one stands out at a glance.
// The account comes from the login record in the session's config folder
// ($CLAUDE_CONFIG_DIR/.claude.json, else ~/.claude.json), so it follows
// whichever account a session runs as. The engine pushes usage figures through
// `session.measure` whenever a window moves a whole point; a one-minute timer
// keeps the countdown current and re-reads the account now and then (/login).

const WINDOW = 'seven_day'
const TICK_MS = 60_000
const ACCOUNT_EVERY_TICKS = 5

// Okabe–Ito: told apart with the common color-vision deficiencies, and dark
// text reads on each of them.
export const PALETTE = ['#E69F00', '#56B4E9', '#009E73', '#F0E442', '#0072B2', '#D55E00', '#CC79A7'] as const

type Account = { email?: string; organizationName?: string; organizationType?: string }

let weekly: SessionRateLimit | undefined
let account: Account | undefined
let now = 0
let ticks = 0

// FNV-1a, 32-bit: small, stable across runs and machines.
export function hash(text: string) {
  let h = 0x811c9dc5
  for (let i = 0; i < text.length; i++) {
    h ^= text.charCodeAt(i)
    h = Math.imul(h, 0x01000193) >>> 0
  }
  return h
}

export const colorFor = (email: string) => PALETTE[hash(email.trim().toLowerCase()) % PALETTE.length]!

export function untilReset(resetsAt: string | undefined, at: number) {
  if (!resetsAt) return undefined
  const ms = Date.parse(resetsAt) - at
  if (!Number.isFinite(ms)) return undefined
  if (ms <= 0) return 'now'
  const mins = Math.floor(ms / 60_000)
  const days = Math.floor(mins / 1440)
  const hours = Math.floor((mins % 1440) / 60)
  if (days > 0) return `${days}d ${hours}h`
  if (hours > 0) return `${hours}h ${mins % 60}m`
  return `${Math.max(1, mins)}m`
}

export function accountText(a: Account | undefined) {
  if (!a?.email) return undefined
  // Name the organization only for a shared one (Team, Enterprise), not a personal plan's.
  const isShared = /team|enterprise/i.test(a.organizationType ?? '')
  return isShared && a.organizationName ? `${a.email} (${a.organizationName})` : a.email
}

export function weeklyText(w: SessionRateLimit | undefined, at: number) {
  if (!w) return undefined
  const left = Math.max(0, Math.round(100 - w.percentUsed))
  const reset = untilReset(w.resetsAt, at)
  const head = left === 0 ? 'Week: limit reached' : `Week: ${left}% left`
  return reset ? `${head} · resets in ${reset}` : head
}

async function readAccount($: EngineInterface): Promise<Account | undefined> {
  const dir = (await $.env.get('CLAUDE_CONFIG_DIR')) || (await $.env.get('HOME')) || (await $.env.get('USERPROFILE'))
  if (!dir) return undefined
  const sep = dir.includes('\\') && !dir.includes('/') ? '\\' : '/'
  try {
    const record = JSON.parse(String(await $.fs.read(dir.replace(/[\\/]+$/, '') + sep + '.claude.json')))
    const o = record?.oauthAccount
    return o ? { email: o.emailAddress, organizationName: o.organizationName, organizationType: o.organizationType } : undefined
  } catch {
    return undefined // no login record (API key, cloud provider, not signed in)
  }
}

async function refresh($: EngineInterface) {
  now = await $.clock.now()
  $.ui.invalidate('ui.render')
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const started = await next(e)
    account = await readAccount($)
    weekly = (await $.session.usage()).rateLimits.find(w => w.kind === WINDOW)
    await refresh($)
    $.clock.every(TICK_MS, () => {
      void (async () => {
        if (++ticks % ACCOUNT_EVERY_TICKS === 0) account = await readAccount($)
        await refresh($)
      })()
    })
    return started
  })

  on('session.measure', async ($, e, next) => {
    if (e.changed.includes('rateLimits')) {
      weekly = e.rateLimits.find(w => w.kind === WINDOW)
      await refresh($)
    }
    return next(e)
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const who = accountText(account)
    const usage = weeklyText(weekly, now)
    if (e.props.hasSurvey || (!who && !usage)) return next(e)

    const { Box, Text } = $.ui.resolve(e)
    return (
      <Box>
        {who && account?.email ? (
          <Text backgroundColor={colorFor(account.email)} color="#000000" weight="bold">
            {` ${who} `}
          </Text>
        ) : null}
        {usage ? <Text dimColor>{who ? `  ${usage}` : usage}</Text> : null}
      </Box>
    )
  })
}
