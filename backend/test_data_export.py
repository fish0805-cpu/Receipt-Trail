from __future__ import annotations

import json
from pathlib import Path

from sqlalchemy import insert

from receipt_trail_api.data_export import export_database
from receipt_trail_api.database import Database
from receipt_trail_api.tables import metadata, users


def test_portable_export_contains_all_tables_but_report_is_redacted(tmp_path: Path) -> None:
    database_path = tmp_path / "source.db"
    url = f"sqlite+pysqlite:///{database_path.as_posix()}"
    database = Database(url)
    metadata.create_all(database.engine)
    with database.transaction() as session:
        session.execute(insert(users).values(
            id=1, name="Private User", email="private@example.test",
            password_hash="private-password-hash",
            created_at="2026-10-15T00:00:00+00:00",
        ))
    database.dispose()

    report = export_database(url, tmp_path / "exports")

    payload = json.loads(report.path.read_text(encoding="utf-8"))
    assert payload["schema_version"] == 1
    assert set(payload["tables"]) == set(metadata.tables)
    assert payload["tables"]["users"][0]["id"] == 1
    assert report.table_counts["users"] == 1
    assert len(report.sha256) == 64
    rendered = str(report)
    assert "private@example.test" not in rendered
    assert "private-password-hash" not in rendered
    assert url not in rendered


def test_export_uses_the_database_snapshot_boundary(tmp_path: Path, monkeypatch) -> None:
    database_path = tmp_path / "snapshot.db"
    url = f"sqlite+pysqlite:///{database_path.as_posix()}"
    database = Database(url)
    metadata.create_all(database.engine)
    database.dispose()
    entered = False
    original = Database.read_snapshot

    def tracking_snapshot(self):
        nonlocal entered
        entered = True
        return original(self)

    monkeypatch.setattr(Database, "read_snapshot", tracking_snapshot)

    export_database(url, tmp_path / "exports")

    assert entered is True
