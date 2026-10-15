from __future__ import annotations

from dataclasses import FrozenInstanceError

import pytest

from receipt_trail_api.config import Settings, normalize_database_url


VALID_AUTH_SECRET = "auth-secret-that-is-long-and-random-123456"
VALID_ADMIN_KEY = "admin-key-that-is-long-and-random-123456"


def production_environment(**overrides: str) -> dict[str, str]:
    environment = {
        "RECEIPT_TRAIL_ENV": "production",
        "DATABASE_URL": "postgresql://receipt_user:password@db.example/receipt_trail",
        "RECEIPT_TRAIL_AUTH_SECRET": VALID_AUTH_SECRET,
        "RECEIPT_TRAIL_PRIZE_ADMIN_KEY": VALID_ADMIN_KEY,
    }
    environment.update(overrides)
    return environment


def test_development_accepts_explicit_sqlite_database() -> None:
    settings = Settings.load(
        {
            "RECEIPT_TRAIL_ENV": "development",
            "DATABASE_URL": "sqlite+pysqlite:///local.db",
            "RECEIPT_TRAIL_AUTH_SECRET": VALID_AUTH_SECRET,
        }
    )

    assert settings.environment == "development"
    assert settings.database_url == "sqlite+pysqlite:///local.db"
    with pytest.raises(FrozenInstanceError):
        settings.environment = "production"  # type: ignore[misc]


@pytest.mark.parametrize(
    ("missing_name", "expected_name"),
    [
        ("DATABASE_URL", "DATABASE_URL"),
        ("RECEIPT_TRAIL_AUTH_SECRET", "RECEIPT_TRAIL_AUTH_SECRET"),
        ("RECEIPT_TRAIL_PRIZE_ADMIN_KEY", "RECEIPT_TRAIL_PRIZE_ADMIN_KEY"),
    ],
)
def test_production_rejects_each_missing_required_variable(
    missing_name: str,
    expected_name: str,
) -> None:
    environment = production_environment()
    del environment[missing_name]

    with pytest.raises(ValueError, match=expected_name):
        Settings.load(environment)


def test_production_rejects_sqlite_database() -> None:
    environment = production_environment(
        DATABASE_URL="sqlite+pysqlite:///production.db"
    )

    with pytest.raises(ValueError, match="PostgreSQL"):
        Settings.load(environment)


@pytest.mark.parametrize(
    ("value", "expected_prefix"),
    [
        ("postgres://user:password@host/db", "postgresql+psycopg://"),
        ("postgresql://user:password@host/db", "postgresql+psycopg://"),
        ("postgresql+psycopg://user:password@host/db", "postgresql+psycopg://"),
    ],
)
def test_postgresql_url_variants_use_psycopg_and_require_tls(
    value: str,
    expected_prefix: str,
) -> None:
    normalized = normalize_database_url(value)

    assert normalized.startswith(expected_prefix)
    assert "sslmode=require" in normalized


def test_normalization_preserves_existing_neon_query_parameters() -> None:
    normalized = normalize_database_url(
        "postgresql://user:password@host/db"
        "?sslmode=require&channel_binding=require"
    )

    assert normalized == (
        "postgresql+psycopg://user:password@host/db"
        "?sslmode=require&channel_binding=require"
    )


@pytest.mark.parametrize(
    ("variable_name", "placeholder"),
    [
        ("RECEIPT_TRAIL_AUTH_SECRET", "change-me"),
        ("RECEIPT_TRAIL_PRIZE_ADMIN_KEY", "your-secret-here"),
    ],
)
def test_production_rejects_placeholder_secrets(
    variable_name: str,
    placeholder: str,
) -> None:
    environment = production_environment(**{variable_name: placeholder})

    with pytest.raises(ValueError, match=variable_name) as error:
        Settings.load(environment)

    assert placeholder not in str(error.value)


def test_configuration_errors_never_reveal_database_credentials() -> None:
    database_password = "top-secret-password"
    environment = production_environment(
        DATABASE_URL=(
            f"postgresql://receipt_user:{database_password}@db.example/receipt_trail"
            "?sslmode=disable"
        )
    )

    with pytest.raises(ValueError, match="TLS") as error:
        Settings.load(environment)

    assert database_password not in str(error.value)
