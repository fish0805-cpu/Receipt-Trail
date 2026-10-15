from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path

from sqlalchemy import select

from receipt_trail_api.database import Database
from receipt_trail_api.tables import metadata


@dataclass(frozen=True, slots=True)
class ExportReport:
    path: Path
    table_counts: dict[str, int]
    sha256: str

    def __str__(self) -> str:
        counts = " ".join(
            f"{name}={count}" for name, count in self.table_counts.items()
        )
        return f"file={self.path.name} sha256={self.sha256} {counts}"


def export_database(database_url: str, output_dir: Path) -> ExportReport:
    database = Database(database_url)
    try:
        with database.read_snapshot() as session:
            tables = {
                name: [
                    {column.name: row._mapping[column.name] for column in table.columns}
                    for row in session.execute(select(table)).all()
                ]
                for name, table in metadata.tables.items()
            }
    finally:
        database.dispose()

    exported_at = datetime.now(UTC)
    payload = {
        "schema_version": 1,
        "exported_at": exported_at.isoformat(),
        "tables": tables,
    }
    encoded = json.dumps(
        payload,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
        default=str,
    ).encode("utf-8")
    output_dir.mkdir(parents=True, exist_ok=True)
    name = exported_at.strftime("receipt-trail-export-%Y%m%dT%H%M%S%fZ.json")
    destination = output_dir / name
    temporary = destination.with_suffix(".json.tmp")
    try:
        temporary.write_bytes(encoded)
        temporary.replace(destination)
    finally:
        temporary.unlink(missing_ok=True)
    return ExportReport(
        path=destination,
        table_counts={name: len(rows) for name, rows in tables.items()},
        sha256=hashlib.sha256(encoded).hexdigest(),
    )
