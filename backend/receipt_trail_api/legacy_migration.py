from __future__ import annotations

import hashlib
import json
import sqlite3
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path
from urllib.parse import quote

from sqlalchemy import and_, func, insert, select, text
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from receipt_trail_api.database import Database
from receipt_trail_api.schemas import invoice_period
from receipt_trail_api.tables import (
    metadata,
    prize_number_snapshots,
    receipt_tombstones,
    receipts,
    refresh_tokens,
    sync_operations,
    users,
)


TABLES = (
    users,
    refresh_tokens,
    receipts,
    sync_operations,
    receipt_tombstones,
    prize_number_snapshots,
)


class MigrationError(RuntimeError):
    pass


class MigrationConflictError(MigrationError):
    pass


@dataclass(frozen=True, slots=True)
class TableMigrationStats:
    source_count: int
    inserted_count: int
    skipped_count: int
    target_count: int
    source_digest: str
    target_digest: str


@dataclass(frozen=True, slots=True)
class MigrationReport:
    applied: bool
    tables: dict[str, TableMigrationStats]
    backup_created: bool

    def __str__(self) -> str:
        lines = [
            f"mode={'apply' if self.applied else 'dry-run'}",
            f"backup_created={str(self.backup_created).lower()}",
        ]
        for name, stats in self.tables.items():
            lines.append(
                f"{name}: source={stats.source_count} inserted={stats.inserted_count} "
                f"skipped={stats.skipped_count} target={stats.target_count} "
                f"source_digest={stats.source_digest} target_digest={stats.target_digest}"
            )
        return "\n".join(lines)


def _canonical_digest(rows: list[dict[str, object]]) -> str:
    canonical_rows = [
        json.dumps(row, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
        for row in rows
    ]
    canonical = "[" + ",".join(sorted(canonical_rows)) + "]"
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


def _read_source(source: Path) -> dict[str, list[dict[str, object]]]:
    if not source.is_file():
        raise MigrationError("legacy source database does not exist")
    uri = f"file:{quote(source.resolve().as_posix(), safe='/:')}?mode=ro"
    connection = sqlite3.connect(uri, uri=True)
    connection.row_factory = sqlite3.Row
    try:
        connection.execute("BEGIN")
        found = {
            row["name"]
            for row in connection.execute(
                "SELECT name FROM sqlite_master WHERE type = 'table'"
            ).fetchall()
        }
        missing = [table.name for table in TABLES if table.name not in found]
        if missing:
            raise MigrationError(
                "legacy source is missing required tables: " + ", ".join(missing)
            )
        extracted: dict[str, list[dict[str, object]]] = {}
        receipt_defaults = {"subtotal", "discount", "seller_tax_id", "period"}
        for table in TABLES:
            available = {
                row["name"]
                for row in connection.execute(
                    f'PRAGMA table_info("{table.name}")'
                ).fetchall()
            }
            required = {column.name for column in table.columns}
            allowed_missing = receipt_defaults if table.name == "receipts" else set()
            unsupported = required - available - allowed_missing
            if unsupported:
                raise MigrationError(
                    f"legacy source has unsupported schema in {table.name}"
                )
            converted: list[dict[str, object]] = []
            for row in connection.execute(f'SELECT * FROM "{table.name}"').fetchall():
                value = {
                    column.name: row[column.name]
                    for column in table.columns
                    if column.name in available
                }
                if table.name == "receipts":
                    value.setdefault("subtotal", row["total"])
                    value.setdefault("discount", 0)
                    value.setdefault("seller_tax_id", None)
                    value.setdefault(
                        "period",
                        invoice_period(datetime.fromisoformat(row["purchased_at"])),
                    )
                converted.append(value)
            extracted[table.name] = converted
    except sqlite3.DatabaseError as error:
        raise MigrationError("legacy source could not be read safely") from error
    finally:
        connection.close()

    user_ids = {row["id"] for row in extracted["users"]}
    for table_name in (
        "refresh_tokens", "receipts", "sync_operations", "receipt_tombstones"
    ):
        if any(row["user_id"] not in user_ids for row in extracted[table_name]):
            raise MigrationError(f"legacy source has invalid relationships in {table_name}")
    return extracted


def _key_filter(table, row: dict[str, object]):
    return and_(*(column == row[column.name] for column in table.primary_key.columns))


def _comparable(table, row) -> dict[str, object]:
    mapping = row._mapping if hasattr(row, "_mapping") else row
    return {column.name: mapping[column.name] for column in table.columns}


def _copy_table(
    session: Session,
    *,
    table,
    rows: list[dict[str, object]],
) -> tuple[int, int]:
    inserted = 0
    skipped = 0
    for source_row in rows:
        existing = session.execute(
            select(table).where(_key_filter(table, source_row))
        ).one_or_none()
        if existing is None:
            session.execute(insert(table).values(**source_row))
            inserted += 1
        elif _comparable(table, existing) == source_row:
            skipped += 1
        else:
            raise MigrationConflictError(
                f"target contains different content in table {table.name}"
            )
    return inserted, skipped


def _target_rows(session: Session, table) -> list[dict[str, object]]:
    return [_comparable(table, row) for row in session.execute(select(table)).all()]


def _backup(source: Path, backup_dir: Path) -> Path:
    backup_dir.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now(UTC).strftime("%Y%m%dT%H%M%S%fZ")
    destination = backup_dir / f"receipt_trail-{timestamp}.db"
    temporary = destination.with_suffix(".db.tmp")
    source_uri = f"file:{quote(source.resolve().as_posix(), safe='/:')}?mode=ro"
    source_connection = sqlite3.connect(source_uri, uri=True)
    destination_connection = sqlite3.connect(temporary)
    try:
        source_connection.backup(destination_connection)
    finally:
        destination_connection.close()
        source_connection.close()
    temporary.replace(destination)
    return destination


def migrate_legacy_database(
    source: Path,
    target_url: str,
    *,
    apply: bool,
    backup_dir: Path,
) -> MigrationReport:
    source = source.resolve()
    backup_created = False
    readable_source = source
    if apply:
        readable_source = _backup(source, backup_dir)
        backup_created = True
    source_rows = _read_source(readable_source)
    source_digests = {
        name: _canonical_digest(rows) for name, rows in source_rows.items()
    }
    database = Database(target_url)
    stats: dict[str, TableMigrationStats] = {}
    try:
        with database.transaction() as session:
            for table in TABLES:
                rows = source_rows[table.name]
                if apply:
                    inserted, skipped = _copy_table(
                        session, table=table, rows=rows
                    )
                else:
                    inserted = 0
                    skipped = sum(
                        1
                        for row in rows
                        if (
                            existing := session.execute(
                                select(table).where(_key_filter(table, row))
                            ).one_or_none()
                        )
                        is not None
                        and _comparable(table, existing) == row
                    )
                target = _target_rows(session, table)
                target_digest = _canonical_digest(target)
                stats[table.name] = TableMigrationStats(
                    source_count=len(rows),
                    inserted_count=inserted,
                    skipped_count=skipped,
                    target_count=len(target),
                    source_digest=source_digests[table.name],
                    target_digest=target_digest,
                )
                if apply and (
                    len(target) != len(rows)
                    or target_digest != source_digests[table.name]
                ):
                    raise MigrationConflictError(
                        f"target verification failed for table {table.name}"
                    )
            if apply and database.engine.dialect.name == "postgresql":
                session.execute(text(
                    "SELECT setval(pg_get_serial_sequence('users', 'id'), "
                    "COALESCE(MAX(id), 1), MAX(id) IS NOT NULL) FROM users"
                ))
    except MigrationError:
        raise
    except SQLAlchemyError as error:
        raise MigrationError("target database operation failed") from error
    finally:
        database.dispose()

    return MigrationReport(
        applied=apply,
        tables=stats,
        backup_created=backup_created,
    )
