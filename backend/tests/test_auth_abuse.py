"""Sign-in codes cannot be brute-forced and code requests cannot be used to flood inboxes."""
from unittest.mock import AsyncMock, patch

import pytest
from fastapi import HTTPException

from app.config import get_settings
from app.routers import auth as auth_router
from app.schemas import MagicCodeRequest
from app.services import rate_limit
from app.services.otp import OtpStore
from tests.fakes import FakeRedis, fake_request


def _store() -> tuple[OtpStore, FakeRedis]:
    store = OtpStore.__new__(OtpStore)
    store.settings = get_settings()
    store.redis = FakeRedis()
    return store, store.redis


@pytest.mark.asyncio
async def test_wrong_guesses_burn_the_code() -> None:
    store, redis = _store()
    await store.save("a@b.com", "123456")
    limit = get_settings().magic_code_max_attempts
    for _ in range(limit):
        assert not await store.verify("a@b.com", "000000")
    assert "magic-code:a@b.com" not in redis.data
    # The right code no longer works once the guess budget is spent.
    assert not await store.verify("a@b.com", "123456")


@pytest.mark.asyncio
async def test_right_code_within_budget_still_works_once() -> None:
    store, _ = _store()
    await store.save("a@b.com", "123456")
    assert not await store.verify("a@b.com", "111111")
    assert await store.verify("a@b.com", "123456")
    assert not await store.verify("a@b.com", "123456")


@pytest.mark.asyncio
async def test_new_code_resets_the_guess_budget() -> None:
    store, redis = _store()
    await store.save("a@b.com", "123456")
    await store.verify("a@b.com", "000000")
    assert redis.data["magic-code-attempts:a@b.com"] == "1"
    await store.save("a@b.com", "654321")
    assert "magic-code-attempts:a@b.com" not in redis.data


@pytest.mark.asyncio
async def test_code_requests_are_limited_per_email_and_ip() -> None:
    settings = get_settings()
    redis = FakeRedis()
    with (
        patch.object(rate_limit.Redis, "from_url", return_value=redis),
        patch.object(auth_router.otp_store, "save", new=AsyncMock()),
        patch.object(auth_router.email_sender, "send_magic_code", new=AsyncMock()) as send,
    ):
        for _ in range(settings.magic_code_requests_per_email):
            await auth_router.request_magic_code(MagicCodeRequest(email="parent@example.com"), fake_request())
        with pytest.raises(HTTPException) as exc:
            await auth_router.request_magic_code(MagicCodeRequest(email="parent@example.com"), fake_request())
        assert exc.value.status_code == 429
        assert send.await_count == settings.magic_code_requests_per_email

        # Same network, many different emails: the per-IP cap kicks in too.
        with pytest.raises(HTTPException) as exc:
            for i in range(settings.magic_code_requests_per_ip + 1):
                await auth_router.request_magic_code(
                    MagicCodeRequest(email=f"p{i}@example.com"), fake_request(ip="198.51.100.9")
                )
        assert exc.value.status_code == 429


def test_client_ip_prefers_first_forwarded_hop() -> None:
    assert rate_limit.client_ip(fake_request(forwarded="1.2.3.4, 10.0.0.1")) == "1.2.3.4"
    assert rate_limit.client_ip(fake_request(ip="9.9.9.9")) == "9.9.9.9"
