import asyncio
import smtplib
import ssl
from email.message import EmailMessage
from email.utils import formataddr

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

    def _from_display(self) -> str:
        s = self.settings
        # Prefer Graph mailbox; fall back to SMTP from.
        addr = (s.ms_graph_sender or s.smtp_from_email or "contact@globinary.io").strip()
        name = (s.smtp_from_name or "BloomDue").strip()
        return formataddr((name, addr))

    def _team_inbox(self) -> str:
        s = self.settings
        return (s.beta_request_to_email or "contact@globinary.io").strip()

    async def send_magic_code(self, email: str, code: str) -> None:
        subject = "Your BloomDue sign-in code"
        body = (
            f"Your BloomDue sign-in code is {code}.\n\n"
            f"It expires in {self.settings.magic_code_expire_minutes} minutes.\n\n"
            "If you didn't request this, you can ignore this email.\n\n"
            "Questions? contact@globinary.io\n"
            "https://bloomdue.baby/\n"
        )
        await self._send(
            to=email,
            subject=subject,
            text=body,
            reply_to="contact@globinary.io",
        )

    async def send_beta_request(
        self,
        *,
        applicant_email: str,
        name: str,
        platform: str,
        message: str,
    ) -> None:
        display_name = name.strip() or "(not provided)"
        note = message.strip() or "(none)"
        platform_label = platform.strip() or "unspecified"
        subject = f"Beta request · {display_name if name.strip() else applicant_email}"
        body = (
            "New BloomDue private beta request\n"
            "================================\n\n"
            f"Name: {display_name}\n"
            f"Email: {applicant_email}\n"
            f"Platform: {platform_label}\n"
            f"Message:\n{note}\n\n"
            "Reply to this email to respond to the applicant.\n"
            "— BloomDue (bloomdue.baby)\n"
        )
        await self._send(
            to=self._team_inbox(),
            subject=subject,
            text=body,
            reply_to=applicant_email,
        )

    async def send_beta_auto_reply(self, *, applicant_email: str, name: str) -> None:
        greeting = f"Hi {name.strip()}," if name.strip() else "Hi,"
        subject = "We received your BloomDue beta request"
        body = (
            f"{greeting}\n\n"
            "Thanks for asking to join the BloomDue private beta — we got your request.\n\n"
            "We’ll review it and follow up at this email address when a spot is ready. "
            "BloomDue is free during private beta: no ads, no guilt, no complicated setup.\n\n"
            "If you didn’t request this, you can ignore this message.\n\n"
            "Warmly,\n"
            "The BloomDue team\n"
            "contact@globinary.io\n"
            "https://bloomdue.baby/\n"
        )
        await self._send(
            to=applicant_email,
            subject=subject,
            text=body,
            reply_to="contact@globinary.io",
        )

    async def _send(
        self,
        *,
        to: str,
        subject: str,
        text: str,
        reply_to: str | None = None,
    ) -> None:
        # Prefer Microsoft Graph (same credentials as globinary.io) when configured.
        # SMTP (PrivateEmail hello@) is legacy and often broken.
        if self.graph_configured:
            await self._send_graph(
                to=to,
                subject=subject,
                text=text,
                reply_to=reply_to,
            )
            return
        if self.smtp_configured:
            await asyncio.to_thread(
                self._send_smtp,
                to=to,
                subject=subject,
                text=text,
                reply_to=reply_to,
            )
            return
        if self.settings.dev_magic_code_log:
            print(f"Bloomdue email (dev log) to={to} subject={subject!r}\n{text}")
            return
        raise RuntimeError("Email delivery is not configured")

    def _send_smtp(
        self,
        *,
        to: str,
        subject: str,
        text: str,
        reply_to: str | None,
    ) -> None:
        s = self.settings
        msg = EmailMessage()
        msg["Subject"] = subject
        msg["From"] = self._from_display()
        msg["To"] = to
        if reply_to:
            msg["Reply-To"] = reply_to
        msg.set_content(text)

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

    async def _send_graph(
        self,
        *,
        to: str,
        subject: str,
        text: str,
        reply_to: str | None,
    ) -> None:
        token = await self._get_graph_token()
        sender = self.settings.ms_graph_sender.strip()
        endpoint = f"https://graph.microsoft.com/v1.0/users/{sender}/sendMail"
        message: dict = {
            "subject": subject,
            "body": {"contentType": "Text", "content": text},
            "toRecipients": [{"emailAddress": {"address": to}}],
            # Friendly From name when the mailbox display name differs.
            "from": {
                "emailAddress": {
                    "name": self.settings.smtp_from_name or "BloomDue",
                    "address": sender,
                }
            },
        }
        if reply_to:
            message["replyTo"] = [{"emailAddress": {"address": reply_to}}]

        payload = {"message": message, "saveToSentItems": "true"}
        async with httpx.AsyncClient(timeout=20) as client:
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
        async with httpx.AsyncClient(timeout=15) as client:
            response = await client.post(url, data=data)
            response.raise_for_status()
            return response.json()["access_token"]
