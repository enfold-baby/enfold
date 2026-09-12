#!/usr/bin/env python3
"""Send one SES test from the running API process. Usage:

    python -m scripts.send_test_email raul@globinary.io
"""

from __future__ import annotations

import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.services.email import EmailSender  # noqa: E402


async def main() -> None:
    to = (sys.argv[1] if len(sys.argv) > 1 else "").strip()
    if not to:
        raise SystemExit("usage: python -m scripts.send_test_email <address>")
    sender = EmailSender()
    print(f"ses={sender.ses_configured} smtp={sender.smtp_configured} graph={sender.graph_configured}")
    print(f"from={sender._from_display()}")
    message_id = await sender.send_ops_test(to)
    print(f"sent to={to} id={message_id}")


if __name__ == "__main__":
    asyncio.run(main())
