from __future__ import annotations

from datetime import UTC, date, datetime
from pathlib import Path

import pytest

from receipt_trail_api.database import Database
from receipt_trail_api.domain import PrizeSnapshotRecord
from receipt_trail_api.repositories.prizes import PrizeNumberRepository
from receipt_trail_api.tables import metadata


@pytest.fixture
def repository(tmp_path: Path) -> PrizeNumberRepository:
    database = Database(f"sqlite+pysqlite:///{(tmp_path / 'prizes.db').as_posix()}")
    metadata.create_all(database.engine)
    try:
        yield PrizeNumberRepository(database)
    finally:
        database.dispose()


def snapshot(*, checksum: str = "checksum-a") -> PrizeSnapshotRecord:
    return PrizeSnapshotRecord(
        term="11501-02",
        special_prize="12345678",
        grand_prize="87654321",
        first_prizes=("11111111", "22222222", "33333333"),
        additional_sixth_prizes=("123",),
        prize_amounts=(("special", 10_000_000), ("sixth", 200)),
        draw_date=date(2026, 3, 25),
        claim_start_date=date(2026, 4, 6),
        claim_end_date=date(2026, 7, 6),
        source_url="https://example.test/prizes",
        published_at=datetime(2026, 3, 25, tzinfo=UTC),
        updated_at=datetime(2026, 3, 25, tzinfo=UTC),
        checksum=checksum,
    )


def test_missing_prize_term_returns_none(repository: PrizeNumberRepository) -> None:
    assert repository.get("11501-02") is None


def test_first_upsert_creates_and_identical_upsert_is_idempotent(
    repository: PrizeNumberRepository,
) -> None:
    record = snapshot()

    stored, created = repository.upsert(record)
    repeated, repeated_created = repository.upsert(record)

    assert (stored, created) == (record, True)
    assert (repeated, repeated_created) == (record, False)


def test_changed_snapshot_replaces_same_unique_term(
    repository: PrizeNumberRepository,
) -> None:
    repository.upsert(snapshot())
    changed = snapshot(checksum="checksum-b")

    stored, created = repository.upsert(changed)

    assert created is False
    assert stored == changed
    assert repository.get(changed.term) == changed
