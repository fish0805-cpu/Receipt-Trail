from __future__ import annotations

from pathlib import Path

import pytest
from sqlalchemy import func, insert, select
from sqlalchemy.exc import IntegrityError

from receipt_trail_api.database import Database, _snapshot_isolation_level
from receipt_trail_api.tables import metadata


EXPECTED_TABLES = {
    "users",
    "refresh_tokens",
    "receipts",
    "sync_operations",
    "receipt_tombstones",
    "prize_number_snapshots",
}


def sqlite_url(path: Path) -> str:
    return f"sqlite+pysqlite:///{path.as_posix()}"


@pytest.fixture
def database(tmp_path: Path) -> Database:
    value = Database(sqlite_url(tmp_path / "database.db"))
    with value.transaction() as session:
        metadata.create_all(session.get_bind())
    try:
        yield value
    finally:
        value.dispose()


def test_metadata_contains_the_six_approved_tables() -> None:
    assert set(metadata.tables) == EXPECTED_TABLES


def test_transaction_commits_on_success(database: Database) -> None:
    users = metadata.tables["users"]
    with database.transaction() as session:
        session.execute(
            insert(users).values(
                name="Committed user",
                email="committed@example.test",
                password_hash="hash",
                created_at="2026-10-15T00:00:00+00:00",
            )
        )

    with database.transaction() as session:
        count = session.scalar(select(func.count()).select_from(users))

    assert count == 1


def test_transaction_rolls_back_on_exception(database: Database) -> None:
    users = metadata.tables["users"]

    with pytest.raises(RuntimeError, match="stop transaction"):
        with database.transaction() as session:
            session.execute(
                insert(users).values(
                    name="Rolled back user",
                    email="rollback@example.test",
                    password_hash="hash",
                    created_at="2026-10-15T00:00:00+00:00",
                )
            )
            raise RuntimeError("stop transaction")

    with database.transaction() as session:
        count = session.scalar(select(func.count()).select_from(users))

    assert count == 0


def test_sqlite_foreign_keys_are_enforced(database: Database) -> None:
    refresh_tokens = metadata.tables["refresh_tokens"]

    with pytest.raises(IntegrityError):
        with database.transaction() as session:
            session.execute(
                insert(refresh_tokens).values(
                    token_hash="orphan-token",
                    user_id=999,
                    expires_at="2026-11-15T00:00:00+00:00",
                    revoked_at=None,
                )
            )


def test_healthcheck_runs_a_lightweight_query(database: Database) -> None:
    assert database.healthcheck() is True
def test_database_normalizes_render_style_postgres_url(monkeypatch) -> None:
    captured: dict[str, str] = {}

    def fake_create_engine(url: str, **_options):
        captured["url"] = url
        raise RuntimeError("engine construction reached")

    monkeypatch.setattr("receipt_trail_api.database.create_engine", fake_create_engine)
    with pytest.raises(RuntimeError, match="construction reached"):
        Database("postgres://user:pass@example.test/database")

    assert captured["url"].startswith("postgresql+psycopg://")
    assert "sslmode=require" in captured["url"]


def test_postgres_exports_request_a_repeatable_read_snapshot() -> None:
    assert _snapshot_isolation_level("postgresql") == "REPEATABLE READ"
    assert _snapshot_isolation_level("sqlite") is None
