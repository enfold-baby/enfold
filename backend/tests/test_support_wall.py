import hashlib
import hmac
import json
import time

from app.services.stripe_webhook import clean_link, parse_checkout_session, tier_for, verify_signature


def _sign(payload: bytes, secret: str, ts: int) -> str:
    sig = hmac.new(secret.encode(), f"{ts}.".encode() + payload, hashlib.sha256).hexdigest()
    return f"t={ts},v1={sig}"


def test_signature_accepts_valid_and_rejects_tampered() -> None:
    body = b'{"id":"evt_1"}'
    ts = int(time.time())
    header = _sign(body, "whsec_test", ts)
    assert verify_signature(body, header, "whsec_test", now=ts)
    assert not verify_signature(body + b" ", header, "whsec_test", now=ts)
    assert not verify_signature(body, header, "whsec_other", now=ts)
    assert not verify_signature(body, header, "whsec_test", now=ts + 1000)  # stale
    assert not verify_signature(body, "", "whsec_test", now=ts)


def test_tiers_and_links() -> None:
    assert tier_for(500, 1) == "tea"
    assert tier_for(1200, 1) == "nest"
    assert tier_for(3000, 1) == "moon"
    assert tier_for(700, 7) == "wish"
    assert clean_link("enfold.baby") == "https://enfold.baby"
    assert clean_link("javascript:alert(1)") == ""
    assert clean_link("  ") == ""


def test_parse_checkout_session_reads_custom_fields() -> None:
    session = {
        "id": "cs_test_1",
        "livemode": False,
        "amount_total": 1200,
        "currency": "eur",
        "payment_status": "paid",
        "customer_details": {
            "email": "a@b.c",
            "name": "Raul Test",
            "address": {"city": "Baia Mare", "country": "RO", "line1": "Str. Lazuri 18", "postal_code": "430414", "line2": None},
        },
        "business_name": "GLOBINARY DEVELOPMENT SYSTEM SRL",
        "custom_fields": [
            {"key": "taxidorcuioptionalforaninvoice", "type": "text", "text": {"value": "RO54530880"}},
            {"key": "showmymoononthesupporterswall", "type": "dropdown", "dropdown": {"value": "Yes, show my name"}},
            {"key": "yourwebsiteorprofilelinkoptional", "type": "text", "text": {"value": "globinary.io"}},
        ],
    }
    data = parse_checkout_session(session)
    assert data["tier"] == "nest"
    assert data["tax_id"] == "RO54530880"
    assert data["show_on_wall"] is True
    assert data["link"] == "https://globinary.io"
    assert data["business_name"].startswith("GLOBINARY")
    assert data["address"]["city"] == "Baia Mare" and "line2" not in data["address"]
    assert data["livemode"] is False
