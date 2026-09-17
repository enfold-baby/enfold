import hmac

from redis.asyncio import Redis

from app.config import get_settings


class OtpStore:
    def __init__(self) -> None:
        settings = get_settings()
        self.settings = settings
        self.redis = Redis.from_url(settings.redis_url, decode_responses=True)

    async def save(self, email: str, code: str) -> None:
        await self.redis.delete(f"magic-code-attempts:{email}")
        await self.redis.setex(
            f"magic-code:{email}",
            self.settings.magic_code_expire_minutes * 60,
            code,
        )

    async def verify(self, email: str, code: str) -> bool:
        key = f"magic-code:{email}"
        attempts_key = f"magic-code-attempts:{email}"
        expected = await self.redis.get(key)
        if expected is None:
            return False
        if not hmac.compare_digest(expected, code):
            attempts = await self.redis.incr(attempts_key)
            if attempts == 1:
                await self.redis.expire(attempts_key, self.settings.magic_code_expire_minutes * 60)
            if attempts >= max(1, self.settings.magic_code_max_attempts):
                # Burn the code: the parent asks for a fresh one, a guesser starts over.
                await self.redis.delete(key, attempts_key)
            return False
        await self.redis.delete(key, attempts_key)
        return True
