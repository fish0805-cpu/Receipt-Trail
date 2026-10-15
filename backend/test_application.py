from __future__ import annotations

from pathlib import Path

from fastapi.testclient import TestClient
from sqlalchemy import text

from receipt_trail_api.application import create_app
from receipt_trail_api.config import Settings
from receipt_trail_api.database import Database
from receipt_trail_api.tables import metadata


def test_receipt_database_failure_returns_safe_503(tmp_path: Path) -> None:
    url = f"sqlite+pysqlite:///{(tmp_path / 'http.db').as_posix()}"
    settings = Settings.load(
        {
            "RECEIPT_TRAIL_ENV": "test",
            "DATABASE_URL": url,
            "RECEIPT_TRAIL_AUTH_SECRET": "test-auth-secret",
            "RECEIPT_TRAIL_PRIZE_ADMIN_KEY": "test-admin-key",
        }
    )
    database = Database(url)
    metadata.create_all(database.engine)
    app = create_app(settings=settings, database=database)

    try:
        with TestClient(app) as client:
            registered = client.post(
                "/auth/register",
                json={
                    "name": "測試使用者",
                    "email": "failure@example.test",
                    "password": "correct-password",
                },
            )
            assert registered.status_code == 201
            access_token = registered.json()["access_token"]
            with database.engine.begin() as connection:
                connection.execute(text("DROP TABLE receipts"))

            response = client.get(
                "/receipts",
                headers={"Authorization": f"Bearer {access_token}"},
            )

        assert response.status_code == 503, response.text
        assert response.json() == {
            "detail": "雲端服務暫時無法使用，請稍後再試。"
        }
        assert url not in response.text
    finally:
        database.dispose()
