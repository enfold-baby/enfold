"""Email delivery. AWS SES first (same pattern as FormKiosk), then SMTP, then Graph."""

from __future__ import annotations

import asyncio
import logging
import smtplib
import ssl
from email.message import EmailMessage
from email.utils import formataddr

import httpx

from app.config import get_settings

logger = logging.getLogger("enfold.email")

_SITE = "https://enfold.baby/"
_DEFAULT_FROM_EMAIL = "noreply@enfold.baby"
_DEFAULT_FROM_NAME = "Enfold"
_DEFAULT_CONTACT = "support@enfold.baby"


class EmailSender:
    def __init__(self) -> None:
        self.settings = get_settings()

    @property
    def ses_configured(self) -> bool:
        s = self.settings
        return bool(
            s.ses_region
            and s.ses_access_key_id
            and s.ses_secret_access_key
            and self._from_email
        )

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
        return self.ses_configured or self.smtp_configured or self.graph_configured

    @property
    def _from_email(self) -> str:
        return (self.settings.smtp_from_email or _DEFAULT_FROM_EMAIL).strip()

    @property
    def _from_name(self) -> str:
        return (self.settings.smtp_from_name or _DEFAULT_FROM_NAME).strip()

    def _from_display(self) -> str:
        return formataddr((self._from_name, self._from_email))

    def _contact_inbox(self) -> str:
        return (self.settings.contact_email or _DEFAULT_CONTACT).strip()

    def _team_inbox(self) -> str:
        s = self.settings
        return (s.beta_request_to_email or self._contact_inbox()).strip()

    async def send_magic_code(self, email: str, code: str) -> None:
        subject = "Your Enfold sign-in code"
        body = (
            f"Your Enfold sign-in code is {code}.\n\n"
            f"It expires in {self.settings.magic_code_expire_minutes} minutes.\n\n"
            "If you didn't request this, you can ignore this email.\n\n"
            f"Questions? {self._contact_inbox()}\n"
            f"{_SITE}\n"
        )
        await self._send(
            to=email,
            subject=subject,
            text=body,
            reply_to=self._contact_inbox(),
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
        subject = f"Enfold launch request · {display_name if name.strip() else applicant_email}"
        body = (
            "New Enfold launch-notify request\n"
            "================================\n\n"
            f"Name: {display_name}\n"
            f"Email: {applicant_email}\n"
            f"Platform: {platform_label}\n"
            f"Message:\n{note}\n\n"
            "Reply to this email to respond to the applicant.\n"
            f"— Enfold ({_SITE})\n"
        )
        await self._send(
            to=self._team_inbox(),
            subject=subject,
            text=body,
            reply_to=applicant_email,
        )

    async def send_beta_auto_reply(self, *, applicant_email: str, name: str) -> None:
        greeting = f"Hi {name.strip()}," if name.strip() else "Hi,"
        subject = "You’re on the Enfold launch list"
        body = (
            f"{greeting}\n\n"
            "Thanks for asking about Enfold — we received your request.\n\n"
            "Enfold is heading to Google Play shortly, then the App Store right after. "
            "No ads, no guilt, no complicated setup. We’ll email you at this address "
            "when Android is live, and again when iOS follows.\n\n"
            "If you didn't request this, you can ignore this message.\n\n"
            "Warmly,\n"
            "The Enfold team\n"
            f"{self._contact_inbox()}\n"
            f"{_SITE}\n"
        )
        await self._send(
            to=applicant_email,
            subject=subject,
            text=body,
            reply_to=self._contact_inbox(),
        )

    async def send_ops_test(self, to: str) -> str:
        """One-shot deliverability check. Returns the provider message id when SES is used."""
        subject = "Enfold mail test"
        body = (
            "This is a test from Enfold.\n\n"
            f"From: {self._from_display()}\n"
            f"Site: {_SITE}\n"
            "If you received this, AWS SES is sending as noreply@enfold.baby.\n"
        )
        return await self._send(
            to=to,
            subject=subject,
            text=body,
            reply_to=self._contact_inbox(),
        )

    async def _send(
        self,
        *,
        to: str,
        subject: str,
        text: str,
        reply_to: str | None = None,
    ) -> str:
        errors: list[str] = []

        if self.ses_configured:
            try:
                return await asyncio.to_thread(
                    self._send_ses,
                    to=to,
                    subject=subject,
                    text=text,
                    reply_to=reply_to,
                )
            except Exception as exc:  # noqa: BLE001 — fall through to the next provider
                errors.append(f"ses: {exc}")
                logger.warning("EMAIL SES failed to=%s error=%s", to, exc)

        # Graph before SMTP: SMTP on this box currently 535s, and Graph is the
        # working Microsoft 365 path for noreply/contact mail.
        if self.graph_configured:
            try:
                await self._send_graph(
                    to=to,
                    subject=subject,
                    text=text,
                    reply_to=reply_to,
                )
                return "graph"
            except Exception as exc:  # noqa: BLE001
                errors.append(f"graph: {exc}")
                logger.warning("EMAIL Graph failed to=%s error=%s", to, exc)

        if self.smtp_configured:
            try:
                await asyncio.to_thread(
                    self._send_smtp,
                    to=to,
                    subject=subject,
                    text=text,
                    reply_to=reply_to,
                )
                return "smtp"
            except Exception as exc:  # noqa: BLE001
                errors.append(f"smtp: {exc}")
                logger.warning("EMAIL SMTP failed to=%s error=%s", to, exc)

        if self.settings.dev_magic_code_log:
            logger.info("EMAIL (dev log) to=%s subject=%r\n%s", to, subject, text)
            print(f"Enfold email (dev log) to={to} subject={subject!r}\n{text}")
            return "dev-log"
        detail = "; ".join(errors) if errors else "no provider configured"
        raise RuntimeError(f"Email delivery failed ({detail})")

    def _send_ses(
        self,
        *,
        to: str,
        subject: str,
        text: str,
        reply_to: str | None,
    ) -> str:
        import boto3

        s = self.settings
        kwargs: dict = {"region_name": s.ses_region}
        if s.ses_access_key_id:
            kwargs["aws_access_key_id"] = s.ses_access_key_id
            kwargs["aws_secret_access_key"] = s.ses_secret_access_key
        client = boto3.client("ses", **kwargs)
        payload: dict = {
            "Source": self._from_display(),
            "Destination": {"ToAddresses": [to]},
            "Message": {
                "Subject": {"Data": subject, "Charset": "UTF-8"},
                "Body": {"Text": {"Data": text, "Charset": "UTF-8"}},
            },
        }
        if reply_to:
            payload["ReplyToAddresses"] = [reply_to]
        res = client.send_email(**payload)
        message_id = str(res.get("MessageId") or "")
        logger.info(
            "EMAIL sent via SES to=%s subject=%r message_id=%s",
            to,
            subject,
            message_id,
        )
        return message_id

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
            "from": {
                "emailAddress": {
                    "name": self._from_name,
                    "address": sender,
                }
            },
        }
        if reply_to:
            message["replyTo"] = [{"emailAddress": {"address": reply_to}}]

        payload = {"message": message, "saveToSentItems": "false"}
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
