from redis.asyncio import Redis

from app.config import get_settings


class OtpStore:
    def __init__(self) -> None:
        settings = get_settings()
        self.settings = settings
        self.redis = Redis.from_url(settings.redis_url, decode_responses=True)

    async def save(self, email: str, code: str) -> None:
        await self.redis.setex(
            f"magic-code:{email}",
            self.settings.magic_code_expire_minutes * 60,
            code,
        )

    async def verify(self, email: str, code: str) -> bool:
        key = f"magic-code:{email}"
        expected = await self.redis.get(key)
        if expected is None or expected != code:
            return False
        await self.redis.delete(key)
        return True
