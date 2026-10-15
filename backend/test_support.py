from __future__ import annotations

from collections.abc import Iterator
from contextlib import contextmanager
from pathlib import Path

from fastapi.testclient import TestClient

from receipt_trail_api.application import create_app
from receipt_trail_api.config import Settings
from receipt_trail_api.database import Database


@contextmanager
def isolated_client(
    database_path: Path,
    *,
    admin_key: str | None = "test-admin-secret",
) -> Iterator[tuple[TestClient, Database]]:
    url = f"sqlite+pysqlite:///{database_path.as_posix()}"
    environment = {
        "RECEIPT_TRAIL_ENV": "test",
        "DATABASE_URL": url,
        "RECEIPT_TRAIL_AUTH_SECRET": "test-auth-secret",
    }
    if admin_key is not None:
        environment["RECEIPT_TRAIL_PRIZE_ADMIN_KEY"] = admin_key
    settings = Settings.load(environment)
    database = Database(url)
    try:
        with TestClient(create_app(settings=settings, database=database)) as client:
            yield client, database
    finally:
        database.dispose()
