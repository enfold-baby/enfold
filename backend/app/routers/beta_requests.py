from fastapi import APIRouter, HTTPException, Request

from app.auth import normalize_email
from app.config import get_settings
from app.schemas import BetaRequestCreate, BetaRequestResponse
from app.services.email import EmailSender
from app.services.rate_limit import client_ip, enforce_limits

router = APIRouter(prefix="/v1/beta-requests", tags=["beta-requests"])
email_sender = EmailSender()

ALLOWED_PLATFORMS = frozenset({"android", "ios", "both", "web", "unspecified"})


async def _rate_limit_or_raise(ip: str, email: str) -> None:
    settings = get_settings()
    window = max(60, settings.beta_request_rate_limit_window_seconds)
    limit = max(1, settings.beta_request_rate_limit_per_ip)
    await enforce_limits(
        [
            (
                f"beta-request:ip:{ip}",
                limit,
                window,
                "Too many requests from this network. Please try again later.",
            ),
            # Slightly stricter per-email to avoid inbox spam loops.
            (
                f"beta-request:email:{email}",
                max(2, limit // 2),
                window,
                "This email already submitted a request recently. Please try again later.",
            ),
        ]
    )


@router.post("", response_model=BetaRequestResponse)
async def create_beta_request(
    payload: BetaRequestCreate,
    request: Request,
) -> BetaRequestResponse:
    # Honeypot: pretend success so bots don't adapt.
    if payload.website.strip():
        return BetaRequestResponse(status="sent")

    email = normalize_email(str(payload.email))
    name = payload.name.strip()
    message = payload.message.strip()
    platform = payload.platform.strip().lower() or "android"
    if platform not in ALLOWED_PLATFORMS:
        platform = "unspecified"

    await _rate_limit_or_raise(client_ip(request), email)

    try:
        await email_sender.send_beta_request(
            applicant_email=email,
            name=name,
            platform=platform,
            message=message,
        )
        # Auto-reply is best-effort; team notification already succeeded.
        try:
            await email_sender.send_beta_auto_reply(applicant_email=email, name=name)
        except Exception:
            pass
    except Exception as exc:
        raise HTTPException(
            status_code=503,
            detail="We couldn't send your request right now. Please email support@enfold.baby.",
        ) from exc

    return BetaRequestResponse(status="sent")
