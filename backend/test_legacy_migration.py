from __future__ import annotations

import hashlib
import sqlite3
from pathlib import Path

import pytest
from sqlalchemy import func, insert, select
from sqlalchemy import text

import receipt_trail_api.legacy_migration as migration
from receipt_trail_api.database import Database
from receipt_trail_api.legacy_migration import MigrationConflictError, migrate_legacy_database
from receipt_trail_api.tables import (
    metadata,
    prize_number_snapshots,
    receipt_tombstones,
    receipts,
    refresh_tokens,
    sync_operations,
    users,
)


def file_hash(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def sqlite_url(path: Path) -> str:
    return f"sqlite+pysqlite:///{path.as_posix()}"


def seed_source(path: Path) -> None:
    database = Database(sqlite_url(path))
    metadata.create_all(database.engine)
    with database.transaction() as session:
        session.execute(insert(users).values(
            id=7, name="Migration User", email="private@example.test",
            password_hash="private-password-hash",
            created_at="2026-10-15T00:00:00+00:00",
        ))
        session.execute(insert(refresh_tokens).values(
            token_hash="private-refresh-hash", user_id=7,
            expires_at="2026-11-15T00:00:00+00:00", revoked_at=None,
        ))
        session.execute(insert(receipts).values(
            user_id=7, id="receipt-1", store_name="Private Store",
            address="Private Address", purchased_at="2026-10-15T00:00:00+00:00",
            total=208, subtotal=208, discount=0, category="shopping",
            items_json='[{"name":"private item","price":208,"quantity":1}]',
            receipt_number="AB12345678", seller_tax_id="12345678",
            period="11510", raw_text="private OCR text",
            latitude=25.0, longitude=121.5,
            updated_at="2026-10-15T00:00:00+00:00",
        ))
        session.execute(insert(sync_operations).values(
            user_id=7, operation_id="operation-1", kind="upsert",
            receipt_id="receipt-1", completed_at="2026-10-15T00:00:00+00:00",
        ))
        session.execute(insert(receipt_tombstones).values(
            user_id=7, receipt_id="old-receipt",
            deleted_at="2026-10-14T00:00:00+00:00",
        ))
        session.execute(insert(prize_number_snapshots).values(
            term="11510", special_prize="11112222", grand_prize="33334444",
            first_prizes_json='["12345678"]',
            additional_sixth_prizes_json='["999"]',
            prize_amounts_json='{"special":10000000}',
            draw_date="2026-11-25", claim_start_date="2026-12-06",
            claim_end_date="2027-03-05",
            source_url="https://www.etax.nat.gov.tw/",
            published_at="2026-11-25T00:00:00+00:00",
            updated_at="2026-11-25T00:00:00+00:00", checksum="checksum",
        ))
    database.dispose()


def empty_target(path: Path) -> tuple[Database, str]:
    url = sqlite_url(path)
    database = Database(url)
    metadata.create_all(database.engine)
    return database, url


def table_counts(database: Database) -> dict[str, int]:
    with database.transaction() as session:
        return {
            table.name: int(session.scalar(select(func.count()).select_from(table)) or 0)
            for table in metadata.sorted_tables
        }


def test_dry_run_reports_all_tables_without_changing_source_or_target(tmp_path: Path) -> None:
    source = tmp_path / "source.db"
    seed_source(source)
    before = file_hash(source)
    target, target_url = empty_target(tmp_path / "target.db")

    report = migrate_legacy_database(
        source, target_url, apply=False, backup_dir=tmp_path / "backups"
    )

    assert file_hash(source) == before
    assert table_counts(target) == {name: 0 for name in table_counts(target)}
    assert set(report.tables) == {
        "users", "refresh_tokens", "receipts", "sync_operations",
        "receipt_tombstones", "prize_number_snapshots",
    }
    assert all(stats.source_count == 1 for stats in report.tables.values())
    assert not (tmp_path / "backups").exists()
    target.dispose()


def test_apply_creates_backup_preserves_identity_and_is_idempotent(tmp_path: Path) -> None:
    source = tmp_path / "source.db"
    seed_source(source)
    before = file_hash(source)
    target, target_url = empty_target(tmp_path / "target.db")
    backups = tmp_path / "backups"

    first = migrate_legacy_database(source, target_url, apply=True, backup_dir=backups)
    second = migrate_legacy_database(source, target_url, apply=True, backup_dir=backups)

    assert file_hash(source) == before
    assert len(list(backups.glob("receipt_trail-*.db"))) == 2
    assert all(stats.inserted_count == 1 for stats in first.tables.values())
    assert all(stats.skipped_count == 1 for stats in second.tables.values())
    with target.transaction() as session:
        assert session.scalar(select(users.c.id)) == 7
        assert session.scalar(select(receipts.c.raw_text)) == "private OCR text"
    target.dispose()


def test_conflict_and_late_failure_roll_back_without_leaking_values(
    tmp_path: Path, monkeypatch
) -> None:
    source = tmp_path / "source.db"
    seed_source(source)
    before = file_hash(source)
    target, target_url = empty_target(tmp_path / "target.db")
    with target.transaction() as session:
        session.execute(insert(users).values(
            id=7, name="Different", email="different@example.test",
            password_hash="different", created_at="2026-10-15T00:00:00+00:00",
        ))

    with pytest.raises(MigrationConflictError) as conflict:
        migrate_legacy_database(
            source, target_url, apply=True, backup_dir=tmp_path / "conflict-backups"
        )
    assert "private@example.test" not in str(conflict.value)
    assert table_counts(target)["users"] == 1

    with target.transaction() as session:
        session.execute(users.delete())
    original_copy = migration._copy_table

    def fail_late(*args, **kwargs):
        if kwargs["table"].name == "prize_number_snapshots":
            raise RuntimeError("injected late failure")
        return original_copy(*args, **kwargs)

    monkeypatch.setattr(migration, "_copy_table", fail_late)
    with pytest.raises(RuntimeError, match="injected late failure") as failure:
        migrate_legacy_database(
            source, target_url, apply=True, backup_dir=tmp_path / "failure-backups"
        )

    assert file_hash(source) == before
    assert all(count == 0 for count in table_counts(target).values())
    for private_value in (
        "private@example.test", "private-password-hash",
        "private-refresh-hash", "private OCR text",
    ):
        assert private_value not in str(failure.value)
    target.dispose()


def test_old_receipt_schema_is_derived_without_altering_source(tmp_path: Path) -> None:
    source = tmp_path / "old-source.db"
    seed_source(source)
    source_database = Database(sqlite_url(source))
    with source_database.engine.begin() as connection:
        for column in ("subtotal", "discount", "seller_tax_id", "period"):
            connection.execute(text(f"ALTER TABLE receipts DROP COLUMN {column}"))
    source_database.dispose()
    before = file_hash(source)
    target, target_url = empty_target(tmp_path / "target.db")

    migrate_legacy_database(
        source, target_url, apply=True, backup_dir=tmp_path / "backups"
    )

    assert file_hash(source) == before
    with target.transaction() as session:
        row = session.execute(select(receipts)).one()._mapping
        assert row["subtotal"] == row["total"] == 208
        assert row["discount"] == 0
        assert row["seller_tax_id"] is None
        assert row["period"] == "11510"
    target.dispose()


def test_apply_backup_includes_committed_wal_rows(tmp_path: Path) -> None:
    source = tmp_path / "wal-source.db"
    seed_source(source)
    writer = sqlite3.connect(source)
    writer.execute("PRAGMA journal_mode=WAL")
    writer.execute("PRAGMA wal_autocheckpoint=0")
    writer.execute(
        "INSERT INTO users(id, name, email, password_hash, created_at) "
        "VALUES(8, 'WAL User', 'wal@example.test', 'hash', "
        "'2026-10-15T00:00:00+00:00')"
    )
    writer.commit()
    target, target_url = empty_target(tmp_path / "wal-target.db")
    backups = tmp_path / "backups"
    try:
        migrate_legacy_database(source, target_url, apply=True, backup_dir=backups)
    finally:
        writer.close()

    backup = next(backups.glob("receipt_trail-*.db"))
    backup_connection = sqlite3.connect(backup)
    try:
        assert backup_connection.execute(
            "SELECT email FROM users WHERE id = 8"
        ).fetchone() == ("wal@example.test",)
    finally:
        backup_connection.close()
        target.dispose()
