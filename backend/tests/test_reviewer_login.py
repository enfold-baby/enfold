"""The store-review account gets a fixed code and no email."""
from unittest.mock import AsyncMock, patch

import pytest

from app.config import get_settings
from app.routers import auth as auth_router
from app.schemas import MagicCodeRequest
from tests.fakes import fake_request


@pytest.mark.asyncio
async def test_reviewer_email_gets_fixed_code_without_email() -> None:
    settings = get_settings()
    with (
        patch.object(settings, "reviewer_email", "Reviewer@Example.com"),
        patch.object(settings, "reviewer_code", "246810"),
        patch.object(auth_router.otp_store, "save", new=AsyncMock()) as save,
        patch.object(auth_router.email_sender, "send_magic_code", new=AsyncMock()) as send,
        patch.object(auth_router, "enforce_limits", new=AsyncMock()),
    ):
        result = await auth_router.request_magic_code(
            MagicCodeRequest(email="reviewer@example.com"), fake_request()
        )
    assert result == {"status": "sent"}
    save.assert_awaited_once_with("reviewer@example.com", "246810")
    send.assert_not_awaited()


@pytest.mark.asyncio
async def test_other_emails_still_get_random_code_and_email() -> None:
    settings = get_settings()
    with (
        patch.object(settings, "reviewer_email", "reviewer@example.com"),
        patch.object(settings, "reviewer_code", "246810"),
        patch.object(auth_router.otp_store, "save", new=AsyncMock()) as save,
        patch.object(auth_router.email_sender, "send_magic_code", new=AsyncMock()) as send,
        patch.object(auth_router, "enforce_limits", new=AsyncMock()),
    ):
        await auth_router.request_magic_code(MagicCodeRequest(email="parent@example.com"), fake_request())
    assert save.await_args.args[0] == "parent@example.com"
    assert save.await_args.args[1] != "246810"
    send.assert_awaited_once()
