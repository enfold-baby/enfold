import asyncio
import smtplib
import ssl
from email.message import EmailMessage

import httpx

from app.config import get_settings


class EmailSender:
    def __init__(self) -> None:
        self.settings = get_settings()

    @property
    def smtp_configured(self) -> bool:
        s = self.settings
        return bool(s.smtp_host and s.smtp_user and s.smtp_password and s.smtp_from_email)

    @property
    def graph_configured(self) -> bool:
        s = self.settings
        return bool(
            s.ms_graph_tenant_id
            and s.ms_graph_client_id
            and s.ms_graph_client_secret
            and s.ms_graph_sender
        )

    @property
    def configured(self) -> bool:
        return self.smtp_configured or self.graph_configured

    async def send_magic_code(self, email: str, code: str) -> None:
        if self.smtp_configured:
            await asyncio.to_thread(self._send_magic_code_smtp, email, code)
            return
        if self.graph_configured:
            await self._send_magic_code_graph(email, code)
            return
        if self.settings.dev_magic_code_log:
            print(f"Bloomdue magic code for {email}: {code}")

    def _send_magic_code_smtp(self, email: str, code: str) -> None:
        s = self.settings
        msg = EmailMessage()
        msg["Subject"] = "Your BloomDue sign-in code"
        msg["From"] = f"{s.smtp_from_name} <{s.smtp_from_email}>"
        msg["To"] = email
        msg.set_content(
            f"Your BloomDue sign-in code is {code}.\n\n"
            f"It expires in {s.magic_code_expire_minutes} minutes.\n\n"
            "If you didn't request this, you can ignore this email.\n\n"
            "Questions? hello@bloomdue.baby"
        )

        context = ssl.create_default_context()
        if s.smtp_use_ssl:
            with smtplib.SMTP_SSL(
                s.smtp_host, s.smtp_port, context=context, timeout=30
            ) as server:
                server.login(s.smtp_user, s.smtp_password)
                server.send_message(msg)
            return

        with smtplib.SMTP(s.smtp_host, s.smtp_port, timeout=30) as server:
            server.ehlo()
            server.starttls(context=context)
            server.ehlo()
            server.login(s.smtp_user, s.smtp_password)
            server.send_message(msg)

    async def _send_magic_code_graph(self, email: str, code: str) -> None:
        token = await self._get_graph_token()
        endpoint = (
            f"https://graph.microsoft.com/v1.0/users/"
            f"{self.settings.ms_graph_sender}/sendMail"
        )
        payload = {
            "message": {
                "subject": "Your BloomDue sign-in code",
                "body": {
                    "contentType": "Text",
                    "content": (
                        f"Your BloomDue sign-in code is {code}. "
                        f"It expires in {self.settings.magic_code_expire_minutes} minutes."
                    ),
                },
                "toRecipients": [{"emailAddress": {"address": email}}],
            },
            "saveToSentItems": "false",
        }
        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.post(
                endpoint,
                headers={"Authorization": f"Bearer {token}"},
                json=payload,
            )
            response.raise_for_status()

    async def _get_graph_token(self) -> str:
        s = self.settings
        url = f"https://login.microsoftonline.com/{s.ms_graph_tenant_id}/oauth2/v2.0/token"
        data = {
            "client_id": s.ms_graph_client_id,
            "client_secret": s.ms_graph_client_secret,
            "scope": "https://graph.microsoft.com/.default",
            "grant_type": "client_credentials",
        }
        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.post(url, data=data)
            response.raise_for_status()
            return response.json()["access_token"]