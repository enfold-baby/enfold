"""Fixed-window counters in Redis shared by the public, unauthenticated endpoints.

Every counter is a Redis INCR with an expiry set on first hit, so the limit is
per window rather than sliding. That is enough to stop scripted abuse of the
sign-in and contact endpoints without adding a dependency.
"""

from fastapi import HTTPException, Request
from redis.asyncio import Redis

from app.config import get_settings


def client_ip(request: Request) -> str:
    forwarded = request.headers.get("x-forwarded-for", "")
    if forwarded:
        return forwarded.split(",")[0].strip() or "unknown"
    if request.client and request.client.host:
        return request.client.host
    return "unknown"


async def count_hit(redis: Redis, key: str, window_seconds: int) -> int:
    """Increment `key`, start its expiry on the first hit, return the new count."""
    count = await redis.incr(key)
    if count == 1:
        await redis.expire(key, max(1, window_seconds))
    return int(count)


async def enforce_limits(limits: list[tuple[str, int, int, str]]) -> None:
    """Apply `(key, limit, window_seconds, detail)` rules in order; 429 on the first breach.

    Counting happens even when a later rule rejects, so a client cannot reset
    its own counters by tripping a different rule first.
    """
    redis = Redis.from_url(get_settings().redis_url, decode_responses=True)
    try:
        for key, limit, window, detail in limits:
            count = await count_hit(redis, key, window)
            if count > max(1, limit):
                raise HTTPException(status_code=429, detail=detail)
    finally:
        await redis.aclose()
