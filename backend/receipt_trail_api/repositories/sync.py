from __future__ import annotations

from datetime import datetime

from sqlalchemy import insert, select, update
from sqlalchemy.orm import Session

from receipt_trail_api.domain import SyncOperationRecord
from receipt_trail_api.tables import receipt_tombstones, sync_operations


class SyncRepository:
    def find_operation(
        self, session: Session, user_id: int, operation_id: str
    ) -> SyncOperationRecord | None:
        row = session.execute(
            select(sync_operations).where(
                sync_operations.c.user_id == user_id,
                sync_operations.c.operation_id == operation_id,
            )
        ).one_or_none()
        if row is None:
            return None
        value = row._mapping
        return SyncOperationRecord(
            user_id=value["user_id"], operation_id=value["operation_id"],
            kind=value["kind"], receipt_id=value["receipt_id"],
            completed_at=datetime.fromisoformat(value["completed_at"]),
        )

    def record_operation(self, session: Session, record: SyncOperationRecord) -> None:
        session.execute(insert(sync_operations).values(
            user_id=record.user_id, operation_id=record.operation_id,
            kind=record.kind, receipt_id=record.receipt_id,
            completed_at=record.completed_at.isoformat(),
        ))

    def has_tombstone(self, session: Session, user_id: int, receipt_id: str) -> bool:
        return session.execute(select(receipt_tombstones.c.receipt_id).where(
            receipt_tombstones.c.user_id == user_id,
            receipt_tombstones.c.receipt_id == receipt_id,
        )).first() is not None

    def upsert_tombstone(
        self, session: Session, user_id: int, receipt_id: str, deleted_at: datetime
    ) -> None:
        if self.has_tombstone(session, user_id, receipt_id):
            session.execute(update(receipt_tombstones).where(
                receipt_tombstones.c.user_id == user_id,
                receipt_tombstones.c.receipt_id == receipt_id,
            ).values(deleted_at=deleted_at.isoformat()))
        else:
            session.execute(insert(receipt_tombstones).values(
                user_id=user_id, receipt_id=receipt_id,
                deleted_at=deleted_at.isoformat(),
            ))
