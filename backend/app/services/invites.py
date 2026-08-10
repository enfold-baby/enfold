"""Ephemeral family invite codes in Redis."""

from __future__ import annotations

import secrets
import string
from datetime import datetime, timedelta, timezone

from redis.asyncio import Redis

from app.config import get_settings

_ALPHABET = string.ascii_uppercase + string.digits
# Drop ambiguous chars for partner typing (0/O, 1/I).
_ALPHABET = _ALPHABET.replace("0", "").replace("O", "").replace("1", "").replace("I", "")


class InviteStore:
    def __init__(self) -> None:
        settings = get_settings()
        self.settings = settings
        self.redis = Redis.from_url(settings.redis_url, decode_responses=True)
        # 7 days — enough for a partner to accept calmly.
        self.ttl_seconds = 60 * 60 * 24 * 7

    def _code_key(self, code: str) -> str:
        return f"family-invite:{code.upper()}"

    def _family_key(self, family_id: str) -> str:
        return f"family-invite-active:{family_id}"

    def generate_code(self) -> str:
        # e.g. BLOOM + 4 chars → BLOOMK7XQ
        suffix = "".join(secrets.choice(_ALPHABET) for _ in range(4))
        return f"BLOOM{suffix}"

    async def create(self, family_id: str) -> tuple[str, datetime]:
        """Create (or rotate) an invite for a family. Returns code + expires_at."""
        # Invalidate previous active code for this family, if any.
        old = await self.redis.get(self._family_key(family_id))
        if old:
            await self.redis.delete(self._code_key(old))

        code = self.generate_code()
        # Extremely unlikely collision; regenerate once if needed.
        for _ in range(5):
            if not await self.redis.exists(self._code_key(code)):
                break
            code = self.generate_code()

        await self.redis.setex(self._code_key(code), self.ttl_seconds, family_id)
        await self.redis.setex(self._family_key(family_id), self.ttl_seconds, code)
        expires = datetime.now(timezone.utc) + timedelta(seconds=self.ttl_seconds)
        return code, expires

    async def get_active_code(self, family_id: str) -> str | None:
        return await self.redis.get(self._family_key(family_id))

    async def resolve_family_id(self, code: str) -> str | None:
        return await self.redis.get(self._code_key(code.strip().upper()))
