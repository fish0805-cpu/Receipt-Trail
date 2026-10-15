from __future__ import annotations

import secrets
from collections.abc import Mapping
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit


BACKEND_DIR = Path(__file__).resolve().parent.parent
DEFAULT_SECRET_PATH = BACKEND_DIR / ".auth-secret"
POSTGRESQL_SCHEMES = {
    "postgres",
    "postgresql",
    "postgresql+psycopg",
}
TLS_MODES = {"require", "verify-ca", "verify-full"}
PLACEHOLDER_SECRETS = {
    "change-me",
    "changeme",
    "example",
    "replace-me",
    "secret",
    "your-secret",
    "your-secret-here",
}


def normalize_database_url(value: str) -> str:
    """Return a SQLAlchemy URL while preserving non-driver URL components."""
    stripped = value.strip()
    parsed = urlsplit(stripped)
    if parsed.scheme.lower() not in POSTGRESQL_SCHEMES:
        return stripped

    query = parse_qsl(parsed.query, keep_blank_values=True)
    if not any(key.lower() == "sslmode" for key, _ in query):
        query.append(("sslmode", "require"))
    return urlunsplit(
        (
            "postgresql+psycopg",
            parsed.netloc,
            parsed.path,
            urlencode(query),
            parsed.fragment,
        )
    )


def _load_development_secret(configured: str | None) -> str:
    if configured and configured.strip():
        return configured.strip()
    if DEFAULT_SECRET_PATH.exists():
        stored = DEFAULT_SECRET_PATH.read_text(encoding="utf-8").strip()
        if stored:
            return stored
    generated = secrets.token_urlsafe(64)
    DEFAULT_SECRET_PATH.write_text(generated, encoding="utf-8")
    return generated


def _require_production_value(
    environ: Mapping[str, str],
    variable_name: str,
) -> str:
    value = environ.get(variable_name, "").strip()
    if not value:
        raise ValueError(f"{variable_name} is required in production")
    return value


def _validate_production_secret(value: str, variable_name: str) -> None:
    normalized = value.strip().lower()
    looks_like_template = (
        normalized in PLACEHOLDER_SECRETS
        or normalized.startswith("<")
        or normalized.endswith(">")
    )
    if looks_like_template:
        raise ValueError(f"{variable_name} must not use a placeholder value")


@dataclass(frozen=True, slots=True)
class Settings:
    environment: str
    database_url: str
    auth_secret: str
    prize_admin_key: str | None

    @classmethod
    def load(cls, environ: Mapping[str, str]) -> Settings:
        environment = environ.get("RECEIPT_TRAIL_ENV", "development").strip().lower()
        is_production = environment == "production"

        if is_production:
            raw_database_url = _require_production_value(environ, "DATABASE_URL")
            auth_secret = _require_production_value(
                environ, "RECEIPT_TRAIL_AUTH_SECRET"
            )
            prize_admin_key = _require_production_value(
                environ, "RECEIPT_TRAIL_PRIZE_ADMIN_KEY"
            )
        else:
            legacy_path = environ.get(
                "RECEIPT_TRAIL_DB", str(BACKEND_DIR / "receipt_trail.db")
            )
            raw_database_url = environ.get(
                "DATABASE_URL",
                f"sqlite+pysqlite:///{Path(legacy_path).as_posix()}",
            ).strip()
            auth_secret = _load_development_secret(
                environ.get("RECEIPT_TRAIL_AUTH_SECRET")
            )
            configured_admin_key = environ.get("RECEIPT_TRAIL_PRIZE_ADMIN_KEY")
            prize_admin_key = (
                configured_admin_key.strip() if configured_admin_key else None
            )

        database_url = normalize_database_url(raw_database_url)
        parsed_database_url = urlsplit(database_url)

        if is_production:
            if parsed_database_url.scheme != "postgresql+psycopg":
                raise ValueError("Production DATABASE_URL must use PostgreSQL")
            query = {
                key.lower(): value.lower()
                for key, value in parse_qsl(
                    parsed_database_url.query, keep_blank_values=True
                )
            }
            if query.get("sslmode") not in TLS_MODES:
                raise ValueError("Production DATABASE_URL must enable TLS")
            _validate_production_secret(
                auth_secret, "RECEIPT_TRAIL_AUTH_SECRET"
            )
            assert prize_admin_key is not None
            _validate_production_secret(
                prize_admin_key, "RECEIPT_TRAIL_PRIZE_ADMIN_KEY"
            )

        return cls(
            environment=environment,
            database_url=database_url,
            auth_secret=auth_secret,
            prize_admin_key=prize_admin_key,
        )
