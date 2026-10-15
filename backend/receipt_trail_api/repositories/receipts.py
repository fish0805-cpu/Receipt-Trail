from __future__ import annotations

from dataclasses import replace
from datetime import UTC, datetime

from sqlalchemy import delete, insert, select, update

from receipt_trail_api.database import Database
from receipt_trail_api.domain import ReceiptRecord, SyncOperationRecord
from receipt_trail_api.errors import RepositoryConflictError
from receipt_trail_api.repositories.sync import SyncRepository
from receipt_trail_api.tables import receipts, users


def _lock_user_statement(user_id: int):
    return select(users.c.id).where(users.c.id == user_id).with_for_update()


def _values(user_id: int, value: ReceiptRecord) -> dict[str, object]:
    return {"user_id": user_id, "id": value.id, "store_name": value.store_name,
        "address": value.address, "purchased_at": value.purchased_at.isoformat(),
        "total": value.total, "subtotal": value.subtotal, "discount": value.discount,
        "category": value.category, "items_json": value.items_json,
        "receipt_number": value.receipt_number, "seller_tax_id": value.seller_tax_id,
        "period": value.period, "raw_text": value.raw_text,
        "latitude": value.latitude, "longitude": value.longitude,
        "updated_at": value.updated_at.isoformat()}


def _record(row) -> ReceiptRecord:
    v = row._mapping
    return ReceiptRecord(id=v["id"], store_name=v["store_name"], address=v["address"],
        purchased_at=datetime.fromisoformat(v["purchased_at"]), total=v["total"],
        subtotal=v["subtotal"], discount=v["discount"], category=v["category"],
        items_json=v["items_json"], receipt_number=v["receipt_number"],
        seller_tax_id=v["seller_tax_id"], period=v["period"], raw_text=None,
        latitude=v["latitude"], longitude=v["longitude"],
        updated_at=datetime.fromisoformat(v["updated_at"]))


class ReceiptRepository:
    def __init__(self, database: Database, *, sync_repository: SyncRepository | None = None):
        self._database = database
        self._sync = sync_repository or SyncRepository()

    def list_for_user(self, user_id: int) -> list[ReceiptRecord]:
        with self._database.transaction() as session:
            rows = session.execute(select(receipts).where(
                receipts.c.user_id == user_id).order_by(receipts.c.purchased_at.desc())).all()
        return [_record(row) for row in rows]

    def _replay(self, session, user_id: int, operation_id: str, kind: str, receipt_id: str):
        previous = self._sync.find_operation(session, user_id, operation_id)
        if previous and (previous.kind != kind or previous.receipt_id != receipt_id):
            raise RepositoryConflictError("operation id conflict")
        return previous

    def save(self, user_id: int, operation_id: str, receipt: ReceiptRecord) -> ReceiptRecord:
        safe = replace(receipt, raw_text=None)
        with self._database.transaction() as session:
            session.execute(_lock_user_statement(user_id)).one()
            if self._replay(session, user_id, operation_id, "upsert", receipt.id):
                row = session.execute(select(receipts).where(
                    receipts.c.user_id == user_id, receipts.c.id == receipt.id)).one_or_none()
                return _record(row) if row else safe
            if self._sync.has_tombstone(session, user_id, receipt.id):
                raise RepositoryConflictError("receipt was deleted")
            exists = session.execute(select(receipts.c.id).where(
                receipts.c.user_id == user_id, receipts.c.id == receipt.id)).first()
            if exists:
                values = _values(user_id, safe); values.pop("user_id"); values.pop("id")
                session.execute(update(receipts).where(receipts.c.user_id == user_id,
                    receipts.c.id == receipt.id).values(**values))
            else:
                session.execute(insert(receipts).values(**_values(user_id, safe)))
            self._sync.record_operation(session, SyncOperationRecord(user_id, operation_id,
                "upsert", receipt.id, datetime.now(UTC)))
        return safe

    def delete(self, user_id: int, operation_id: str, receipt_id: str) -> bool:
        with self._database.transaction() as session:
            session.execute(_lock_user_statement(user_id)).one()
            if self._replay(session, user_id, operation_id, "delete", receipt_id):
                return True
            result = session.execute(delete(receipts).where(
                receipts.c.user_id == user_id, receipts.c.id == receipt_id))
            now = datetime.now(UTC)
            self._sync.upsert_tombstone(session, user_id, receipt_id, now)
            self._sync.record_operation(session, SyncOperationRecord(
                user_id, operation_id, "delete", receipt_id, now))
            return bool(result.rowcount)

    def delete_all(self, user_id: int, operation_id: str) -> int:
        with self._database.transaction() as session:
            session.execute(_lock_user_statement(user_id)).one()
            if self._replay(session, user_id, operation_id, "delete", "*"):
                return 0
            ids = list(session.scalars(select(receipts.c.id).where(receipts.c.user_id == user_id)))
            now = datetime.now(UTC)
            for receipt_id in ids:
                self._sync.upsert_tombstone(session, user_id, receipt_id, now)
            session.execute(delete(receipts).where(receipts.c.user_id == user_id))
            self._sync.record_operation(session, SyncOperationRecord(
                user_id, operation_id, "delete", "*", now))
            return len(ids)
