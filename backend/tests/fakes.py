"""Small stand-ins so the auth tests run without Redis or an HTTP server."""

from fastapi import Request


class FakeRedis:
    """Just enough of redis.asyncio for the OTP store and the rate limiter."""

    def __init__(self) -> None:
        self.data: dict[str, str] = {}
        self.ttl: dict[str, int] = {}

    async def get(self, key: str) -> str | None:
        return self.data.get(key)

    async def setex(self, key: str, seconds: int, value: str) -> None:
        self.data[key] = value
        self.ttl[key] = seconds

    async def incr(self, key: str) -> int:
        value = int(self.data.get(key, "0")) + 1
        self.data[key] = str(value)
        return value

    async def expire(self, key: str, seconds: int) -> None:
        self.ttl[key] = seconds

    async def delete(self, *keys: str) -> None:
        for key in keys:
            self.data.pop(key, None)
            self.ttl.pop(key, None)

    async def aclose(self) -> None:
        return None


def fake_request(ip: str = "203.0.113.7", forwarded: str | None = None) -> Request:
    headers = [(b"x-forwarded-for", forwarded.encode())] if forwarded else []
    scope = {"type": "http", "headers": headers, "client": (ip, 12345)}
    return Request(scope)
