/**
 * Best-effort fixed-window rate limiting (pure, environment-free).
 * Runs identically in Deno (Supabase Edge) and Node/vitest.
 *
 * Scope: one Edge isolate is ephemeral and per-region, so the counter only
 * caps bursts reaching the same isolate. It raises the cost of abuse cheaply;
 * the initData HMAC and the replay-nonce table remain the real guards.
 */

export const RATE_LIMIT_MAX = 10
export const RATE_LIMIT_WINDOW_MS = 60_000

interface RateBucket {
  resetAt: number
  count: number
}

export type RateLimiter = {
  /** Returns retry-after seconds when the key is over the limit, else null. */
  check: (key: string, nowMs?: number) => number | null
}

export const createRateLimiter = (
  max: number = RATE_LIMIT_MAX,
  windowMs: number = RATE_LIMIT_WINDOW_MS,
  maxTrackedKeys: number = 10_000
): RateLimiter => {
  const buckets = new Map<string, RateBucket>()

  const sweep = (now: number) => {
    for (const [key, bucket] of buckets) {
      if (bucket.resetAt <= now) buckets.delete(key)
    }
  }

  const check = (key: string, nowMs: number = Date.now()): number | null => {
    if (buckets.size > maxTrackedKeys) sweep(nowMs)
    const bucket = buckets.get(key)
    if (!bucket || bucket.resetAt <= nowMs) {
      buckets.set(key, { resetAt: nowMs + windowMs, count: 1 })
      return null
    }
    bucket.count += 1
    if (bucket.count <= max) return null
    return Math.ceil((bucket.resetAt - nowMs) / 1000)
  }

  return { check }
}
