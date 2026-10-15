from __future__ import annotations

from datetime import UTC, datetime
from pathlib import Path

import pytest
from sqlalchemy.dialects import postgresql

from receipt_trail_api.database import Database
from receipt_trail_api.domain import ReceiptRecord
from receipt_trail_api.errors import RepositoryConflictError
from receipt_trail_api.repositories.auth import AuthRepository
from receipt_trail_api.repositories.receipts import ReceiptRepository, _lock_user_statement
from receipt_trail_api.repositories.sync import SyncRepository
from receipt_trail_api.tables import metadata


@pytest.fixture
def database(tmp_path: Path) -> Database:
    value = Database(f"sqlite+pysqlite:///{(tmp_path / 'receipts.db').as_posix()}")
    metadata.create_all(value.engine)
    try:
        yield value
    finally:
        value.dispose()


def user_id(database: Database, email: str) -> int:
    return AuthRepository(database).create_user(
        name="Person",
        email=email,
        password_hash="hash",
        created_at=datetime(2026, 10, 15, tzinfo=UTC),
    ).id


def receipt(*, total: int = 208) -> ReceiptRecord:
    return ReceiptRecord(
        id="receipt-1",
        store_name="全聯福利中心",
        address="台北市測試路 1 號",
        purchased_at=datetime(2026, 10, 15, 12, tzinfo=UTC),
        total=total,
        subtotal=total,
        discount=0,
        category="購物",
        items_json='[{"name":"商品","amount":208}]',
        receipt_number="CD71853982",
        seller_tax_id="12345678",
        period="11509-10",
        raw_text="private OCR contents",
        latitude=25.04,
        longitude=121.56,
        updated_at=datetime(2026, 10, 15, 12, tzinfo=UTC),
    )


def test_receipt_round_trip_omits_raw_ocr_and_isolates_users(
    database: Database,
) -> None:
    first_user = user_id(database, "first@example.test")
    second_user = user_id(database, "second@example.test")
    repository = ReceiptRepository(database)

    stored = repository.save(first_user, "operation-1", receipt())

    assert stored.raw_text is None
    assert repository.list_for_user(first_user) == [stored]
    assert repository.list_for_user(second_user) == []


def test_save_updates_and_replay_is_idempotent(database: Database) -> None:
    owner = user_id(database, "person@example.test")
    repository = ReceiptRepository(database)
    repository.save(owner, "operation-1", receipt())

    updated = repository.save(owner, "operation-2", receipt(total=300))
    replayed = repository.save(owner, "operation-2", receipt(total=300))

    assert updated.total == 300
    assert replayed == updated
    assert repository.list_for_user(owner) == [updated]


def test_reused_operation_id_with_different_work_conflicts(database: Database) -> None:
    owner = user_id(database, "person@example.test")
    repository = ReceiptRepository(database)
    repository.save(owner, "operation-1", receipt())

    with pytest.raises(RepositoryConflictError):
        repository.delete(owner, "operation-1", "receipt-1")


def test_tombstone_prevents_old_receipt_from_returning(database: Database) -> None:
    owner = user_id(database, "person@example.test")
    repository = ReceiptRepository(database)
    repository.save(owner, "operation-1", receipt())

    assert repository.delete(owner, "operation-2", "receipt-1") is True
    assert repository.delete(owner, "operation-2", "receipt-1") is True
    with pytest.raises(RepositoryConflictError, match="deleted"):
        repository.save(owner, "operation-3", receipt())


def test_delete_all_removes_only_the_owners_receipts(database: Database) -> None:
    first_user = user_id(database, "first@example.test")
    second_user = user_id(database, "second@example.test")
    first = ReceiptRepository(database)
    first.save(first_user, "first-save", receipt())
    second = ReceiptRepository(database)
    second.save(second_user, "second-save", receipt())

    assert first.delete_all(first_user, "first-reset") == 1
    assert first.list_for_user(first_user) == []
    assert second.list_for_user(second_user) != []


class FailingSyncRepository(SyncRepository):
    def record_operation(self, *args, **kwargs):
        raise RuntimeError("injected late failure")


def test_late_operation_failure_rolls_back_receipt_write(database: Database) -> None:
    owner = user_id(database, "person@example.test")
    repository = ReceiptRepository(
        database,
        sync_repository=FailingSyncRepository(),
    )

    with pytest.raises(RuntimeError, match="injected late failure"):
        repository.save(owner, "operation-1", receipt())

    assert ReceiptRepository(database).list_for_user(owner) == []


def test_receipt_mutations_lock_the_account_row_on_postgres() -> None:
    compiled = str(
        _lock_user_statement(7).compile(
            dialect=postgresql.dialect(),
            compile_kwargs={"literal_binds": True},
        )
    ).lower()

    assert "from users" in compiled
    assert "for update" in compiled
