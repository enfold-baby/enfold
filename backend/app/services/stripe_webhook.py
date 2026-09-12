"""Stripe webhook signature check and event parsing, without the stripe SDK."""

from __future__ import annotations

import hashlib
import hmac
import time
from urllib.parse import urlparse

TOLERANCE_SECONDS = 300

TIER_BY_AMOUNT = {500: "tea", 1200: "nest", 3000: "moon"}


def verify_signature(payload: bytes, header: str, secret: str, now: float | None = None) -> bool:
    """Stripe-Signature: t=<ts>,v1=<hex>[,v1=<hex>...]; HMAC-SHA256 of "<ts>.<payload>"."""
    if not secret or not header:
        return False
    parts = dict()
    v1: list[str] = []
    for item in header.split(","):
        key, _, value = item.strip().partition("=")
        if key == "v1":
            v1.append(value)
        elif key:
            parts[key] = value
    ts = parts.get("t")
    if not ts or not v1:
        return False
    try:
        ts_int = int(ts)
    except ValueError:
        return False
    if abs((now if now is not None else time.time()) - ts_int) > TOLERANCE_SECONDS:
        return False
    expected = hmac.new(secret.encode(), f"{ts}.".encode() + payload, hashlib.sha256).hexdigest()
    return any(hmac.compare_digest(expected, candidate) for candidate in v1)


def tier_for(amount_cents: int, quantity: int) -> str:
    if quantity > 1:
        return "wish"
    return TIER_BY_AMOUNT.get(amount_cents, "wish")


def clean_link(raw: str) -> str:
    """Only http(s) links, max 512 chars; bare domains get https://."""
    value = (raw or "").strip()
    if not value:
        return ""
    if not value.lower().startswith(("http://", "https://")):
        value = "https://" + value
    parsed = urlparse(value)
    if parsed.scheme not in ("http", "https") or not parsed.netloc or "." not in parsed.netloc:
        return ""
    return value[:512]


def parse_checkout_session(session: dict) -> dict:
    """Pull what the wall and the invoices need out of a checkout.session object."""
    details = session.get("customer_details") or {}
    address = details.get("address") or {}
    custom: dict[str, str] = {}
    for field in session.get("custom_fields") or []:
        key = str(field.get("key", "")).lower()
        kind = field.get("type")
        value = ""
        if kind == "dropdown":
            value = str((field.get("dropdown") or {}).get("value") or "")
        elif kind == "numeric":
            value = str((field.get("numeric") or {}).get("value") or "")
        else:
            value = str((field.get("text") or {}).get("value") or "")
        custom[key] = value
    tax_id = ""
    link = ""
    show = False
    for key, value in custom.items():
        if "tax" in key or "cui" in key:
            tax_id = value.strip()[:64]
        elif "link" in key or "website" in key or "profile" in key:
            link = clean_link(value)
        elif "wall" in key or "show" in key:
            show = value.strip().lower().startswith("yes")
    quantity = 1
    for item in (session.get("line_items") or {}).get("data") or []:
        quantity = int(item.get("quantity") or 1)
    amount = int(session.get("amount_total") or 0)
    return {
        "stripe_session_id": str(session.get("id") or ""),
        "livemode": bool(session.get("livemode", True)),
        "amount_cents": amount,
        "currency": str(session.get("currency") or "eur").lower(),
        "tier": tier_for(amount, quantity),
        "email": str(details.get("email") or "")[:255],
        "full_name": str(details.get("name") or "")[:255],
        "business_name": str((session.get("business_name") or details.get("business_name") or ""))[:255],
        "tax_id": tax_id,
        "address": {k: v for k, v in address.items() if v},
        "show_on_wall": show,
        "link": link,
    }
