from __future__ import annotations

import os
from concurrent.futures import ThreadPoolExecutor
from datetime import UTC, datetime, timedelta

import pytest
from sqlalchemy import inspect

from receipt_trail_api.config import normalize_database_url
from receipt_trail_api.database import Database
from receipt_trail_api.domain import ReceiptRecord, RefreshTokenRecord
from receipt_trail_api.errors import RecordNotFoundError
from receipt_trail_api.repositories.auth import AuthRepository
from receipt_trail_api.repositories.receipts import ReceiptRepository
from receipt_trail_api.tables import metadata


@pytest.fixture
def postgres_database() -> Database:
    configured = os.environ.get("TEST_POSTGRES_URL")
    if not configured:
        pytest.skip("TEST_POSTGRES_URL is not configured; Neon contract is external-gated")
    url = normalize_database_url(configured)
    if not url.startswith("postgresql+psycopg://"):
        pytest.fail("TEST_POSTGRES_URL must identify an isolated PostgreSQL database")

    database = Database(url)
    metadata.drop_all(database.engine)
    metadata.create_all(database.engine)
    try:
        yield database
    finally:
        metadata.drop_all(database.engine)
        database.dispose()


@pytest.mark.postgres
def test_postgres_database_supports_the_shared_schema(
    postgres_database: Database,
) -> None:
    assert postgres_database.healthcheck() is True
    assert set(metadata.tables) <= set(
        inspect(postgres_database.engine).get_table_names()
    )


@pytest.mark.postgres
def test_postgres_refresh_rotation_is_atomic(
    postgres_database: Database,
) -> None:
    repository = AuthRepository(postgres_database)
    now = datetime(2026, 10, 15, tzinfo=UTC)
    user = repository.create_user(
        name="Concurrent User",
        email="concurrent@example.test",
        password_hash="hash",
        created_at=now,
    )
    repository.store_refresh_token(
        RefreshTokenRecord(
            token_hash="old", user_id=user.id,
            expires_at=now + timedelta(days=1), revoked_at=None,
        )
    )

    def consume(index: int) -> str:
        try:
            repository.consume_refresh_token(
                "old", now=now,
                replacement=RefreshTokenRecord(
                    token_hash=f"replacement-{index}", user_id=user.id,
                    expires_at=now + timedelta(days=2), revoked_at=None,
                ),
            )
            return "success"
        except RecordNotFoundError:
            return "rejected"

    with ThreadPoolExecutor(max_workers=2) as executor:
        outcomes = list(executor.map(consume, range(2)))

    assert sorted(outcomes) == ["rejected", "success"]


@pytest.mark.postgres
def test_postgres_concurrent_operation_replay_is_idempotent(
    postgres_database: Database,
) -> None:
    auth = AuthRepository(postgres_database)
    now = datetime(2026, 10, 15, tzinfo=UTC)
    user = auth.create_user(
        name="Receipt User", email="receipt@example.test",
        password_hash="hash", created_at=now,
    )
    receipt = ReceiptRecord(
        id="receipt-1", store_name="測試店家", address="台北市",
        purchased_at=now, total=100, subtotal=100, discount=0,
        category="shopping", items_json="[]", receipt_number="AB12345678",
        seller_tax_id="12345678", period="11509-10", raw_text=None,
        latitude=None, longitude=None, updated_at=now,
    )
    repository = ReceiptRepository(postgres_database)

    with ThreadPoolExecutor(max_workers=2) as executor:
        stored = list(executor.map(
            lambda _index: repository.save(
                user.id, "same-operation", receipt,
            ),
            range(2),
        ))

    assert stored == [receipt, receipt]
    assert repository.list_for_user(user.id) == [receipt]
