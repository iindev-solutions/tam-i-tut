import { describe, expect, it } from 'vitest'

import { createRateLimiter, RATE_LIMIT_MAX, RATE_LIMIT_WINDOW_MS } from '#telegram-rate-limit'

const minute = (s: number) => s * 1_000

describe('createRateLimiter (telegram-bootstrap)', () => {
  it('allows bursts up to the limit and then reports retry-after', () => {
    const limiter = createRateLimiter()
    for (let i = 0; i < RATE_LIMIT_MAX; i++) {
      expect(limiter.check('ip-a', minute(0))).toBeNull()
    }
    const retryAfter = limiter.check('ip-a', minute(0) + 1_000)
    expect(retryAfter).not.toBeNull()
    expect(retryAfter!).toBeGreaterThan(0)
    expect(retryAfter!).toBeLessThanOrEqual(RATE_LIMIT_WINDOW_MS / 1_000)
  })

  it('keeps limiting for the rest of the window', () => {
    const limiter = createRateLimiter()
    const t0 = minute(5)
    for (let i = 0; i < RATE_LIMIT_MAX; i++) limiter.check('ip-a', t0)
    expect(limiter.check('ip-a', t0 + 10_000)).not.toBeNull()
    expect(limiter.check('ip-a', t0 + 59_999)).not.toBeNull()
  })

  it('opens a fresh window after the previous one expires', () => {
    const limiter = createRateLimiter()
    const t0 = minute(10)
    for (let i = 0; i < RATE_LIMIT_MAX; i++) limiter.check('ip-a', t0)
    expect(limiter.check('ip-a', t0 + RATE_LIMIT_WINDOW_MS + 1)).toBeNull()
  })

  it('tracks keys independently', () => {
    const limiter = createRateLimiter(2, RATE_LIMIT_WINDOW_MS)
    expect(limiter.check('ip-a', minute(0))).toBeNull()
    expect(limiter.check('ip-a', minute(0))).toBeNull()
    expect(limiter.check('ip-a', minute(0))).not.toBeNull()
    expect(limiter.check('ip-b', minute(0))).toBeNull()
  })

  it('sweeps expired keys when the tracking map grows past the cap', () => {
    const limiter = createRateLimiter(1, minute(1), 3)
    limiter.check('old-1', minute(0))
    limiter.check('old-2', minute(0))
    limiter.check('old-3', minute(0))
    // Past the cap: the sweep drops the expired windows...
    expect(limiter.check('new', minute(5))).toBeNull()
    // ...so an old key starts a fresh window instead of staying limited.
    expect(limiter.check('old-1', minute(5))).toBeNull()
  })
})
