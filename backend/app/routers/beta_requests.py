from fastapi import APIRouter, HTTPException, Request
from redis.asyncio import Redis

from app.auth import normalize_email
from app.config import get_settings
from app.schemas import BetaRequestCreate, BetaRequestResponse
from app.services.email import EmailSender

router = APIRouter(prefix="/v1/beta-requests", tags=["beta-requests"])
email_sender = EmailSender()

ALLOWED_PLATFORMS = frozenset({"android", "ios", "both", "web", "unspecified"})


def _client_ip(request: Request) -> str:
    forwarded = request.headers.get("x-forwarded-for", "")
    if forwarded:
        return forwarded.split(",")[0].strip() or "unknown"
    if request.client and request.client.host:
        return request.client.host
    return "unknown"


async def _rate_limit_or_raise(ip: str, email: str) -> None:
    settings = get_settings()
    redis = Redis.from_url(settings.redis_url, decode_responses=True)
    window = max(60, settings.beta_request_rate_limit_window_seconds)
    limit = max(1, settings.beta_request_rate_limit_per_ip)

    try:
        ip_key = f"beta-request:ip:{ip}"
        email_key = f"beta-request:email:{email}"

        ip_count = await redis.incr(ip_key)
        if ip_count == 1:
            await redis.expire(ip_key, window)
        if ip_count > limit:
            raise HTTPException(
                status_code=429,
                detail="Too many requests from this network. Please try again later.",
            )

        email_count = await redis.incr(email_key)
        if email_count == 1:
            await redis.expire(email_key, window)
        # Slightly stricter per-email to avoid inbox spam loops.
        if email_count > max(2, limit // 2):
            raise HTTPException(
                status_code=429,
                detail="This email already submitted a request recently. Please try again later.",
            )
    finally:
        await redis.aclose()


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

    await _rate_limit_or_raise(_client_ip(request), email)

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
            detail="We couldn't send your request right now. Please email hello@bloomdue.baby.",
        ) from exc

    return BetaRequestResponse(status="sent")
