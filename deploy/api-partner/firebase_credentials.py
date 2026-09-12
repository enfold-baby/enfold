from __future__ import annotations

import base64
import json
from pathlib import Path

_UNREGISTERED_STATUSES = {"NOT_FOUND", "UNREGISTERED"}


def token_is_unregistered(status_code: int, body: dict) -> bool:
    if status_code in {404, 410}:
        return True
    status = str(body.get("error", {}).get("status", "")).upper()
    if status in _UNREGISTERED_STATUSES:
        return True
    details = body.get("error", {}).get("details") or []
    for item in details:
        code = str(item.get("errorCode", "")).upper()
        if code in _UNREGISTERED_STATUSES:
            return True
    return False


def load_service_account_info(raw: str) -> dict | None:
    """Parse FIREBASE_SERVICE_ACCOUNT_JSON as JSON, a file path, or base64 JSON."""
    value = (raw or "").strip()
    if not value:
        return None
    if value.startswith("{"):
        parsed = json.loads(value)
        if not isinstance(parsed, dict):
            raise ValueError("service account JSON must be an object")
        return parsed
    path = Path(value)
    if path.is_file():
        parsed = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(parsed, dict):
            raise ValueError("service account file must contain a JSON object")
        return parsed
    decoded = base64.b64decode(value).decode("utf-8")
    if not decoded.lstrip().startswith("{"):
        raise ValueError("FIREBASE_SERVICE_ACCOUNT_JSON is not JSON, a path, or base64 JSON")
    parsed = json.loads(decoded)
    if not isinstance(parsed, dict):
        raise ValueError("service account JSON must be an object")
    return parsed
