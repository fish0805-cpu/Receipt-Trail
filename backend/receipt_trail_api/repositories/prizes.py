from __future__ import annotations

import json
from datetime import date, datetime

from sqlalchemy import insert, select, update
from sqlalchemy.exc import IntegrityError

from receipt_trail_api.database import Database
from receipt_trail_api.domain import PrizeSnapshotRecord
from receipt_trail_api.errors import RepositoryConflictError
from receipt_trail_api.tables import prize_number_snapshots


def _from_row(row) -> PrizeSnapshotRecord:
    values = row._mapping
    return PrizeSnapshotRecord(
        term=values["term"],
        special_prize=values["special_prize"],
        grand_prize=values["grand_prize"],
        first_prizes=tuple(json.loads(values["first_prizes_json"])),
        additional_sixth_prizes=tuple(
            json.loads(values["additional_sixth_prizes_json"])
        ),
        prize_amounts=tuple(json.loads(values["prize_amounts_json"]).items()),
        draw_date=date.fromisoformat(values["draw_date"]),
        claim_start_date=date.fromisoformat(values["claim_start_date"]),
        claim_end_date=date.fromisoformat(values["claim_end_date"]),
        source_url=values["source_url"],
        published_at=datetime.fromisoformat(values["published_at"]),
        updated_at=datetime.fromisoformat(values["updated_at"]),
        checksum=values["checksum"],
    )


def _values(record: PrizeSnapshotRecord) -> dict[str, object]:
    return {
        "term": record.term,
        "special_prize": record.special_prize,
        "grand_prize": record.grand_prize,
        "first_prizes_json": json.dumps(record.first_prizes),
        "additional_sixth_prizes_json": json.dumps(
            record.additional_sixth_prizes
        ),
        "prize_amounts_json": json.dumps(dict(record.prize_amounts)),
        "draw_date": record.draw_date.isoformat(),
        "claim_start_date": record.claim_start_date.isoformat(),
        "claim_end_date": record.claim_end_date.isoformat(),
        "source_url": record.source_url,
        "published_at": record.published_at.isoformat(),
        "updated_at": record.updated_at.isoformat(),
        "checksum": record.checksum,
    }


class PrizeNumberRepository:
    def __init__(self, database: Database) -> None:
        self._database = database

    def get(self, term: str) -> PrizeSnapshotRecord | None:
        with self._database.transaction() as session:
            row = session.execute(
                select(prize_number_snapshots).where(
                    prize_number_snapshots.c.term == term
                )
            ).one_or_none()
        return _from_row(row) if row else None

    def upsert(
        self,
        snapshot: PrizeSnapshotRecord,
    ) -> tuple[PrizeSnapshotRecord, bool]:
        try:
            with self._database.transaction() as session:
                existing = session.execute(
                    select(prize_number_snapshots).where(
                        prize_number_snapshots.c.term == snapshot.term
                    )
                ).one_or_none()
                if existing is None:
                    session.execute(
                        insert(prize_number_snapshots).values(**_values(snapshot))
                    )
                    return snapshot, True
                current = _from_row(existing)
                if current.checksum == snapshot.checksum:
                    return current, False
                session.execute(
                    update(prize_number_snapshots)
                    .where(prize_number_snapshots.c.term == snapshot.term)
                    .values(**_values(snapshot))
                )
                return snapshot, False
        except IntegrityError as error:
            raise RepositoryConflictError("prize snapshot conflict") from error
