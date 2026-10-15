from __future__ import annotations

import os
import secrets
from pathlib import Path

from receipt_trail_api.application import create_app
from receipt_trail_api.config import Settings
from receipt_trail_api.schemas import ReceiptPayload


def load_auth_secret(
    *, environment: str, configured: str | None, secret_path: Path
) -> str:
    """Compatibility helper retained for callers of the original entry point."""
    if configured and configured.strip():
        return configured.strip()
    if environment.strip().lower() == "production":
        raise RuntimeError(
            "RECEIPT_TRAIL_AUTH_SECRET is required in the production environment"
        )
    if secret_path.exists():
        return secret_path.read_text(encoding="utf-8").strip()
    value = secrets.token_urlsafe(64)
    secret_path.write_text(value, encoding="utf-8")
    return value


settings = Settings.load(os.environ)
app = create_app(settings=settings)

__all__ = ["ReceiptPayload", "app", "load_auth_secret"]
