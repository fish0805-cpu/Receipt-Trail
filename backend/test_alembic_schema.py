from pathlib import Path

from alembic import command
from alembic.config import Config
from sqlalchemy import create_engine, inspect


EXPECTED_TABLES = {
    "alembic_version", "users", "refresh_tokens", "receipts",
    "sync_operations", "receipt_tombstones", "prize_number_snapshots",
}


def test_schema_can_upgrade_downgrade_and_upgrade_again(
    tmp_path: Path, monkeypatch
) -> None:
    database_path = tmp_path / "alembic.db"
    url = f"sqlite+pysqlite:///{database_path.as_posix()}"
    monkeypatch.setenv("DATABASE_URL", url)
    config = Config(str(Path(__file__).with_name("alembic.ini")))

    command.upgrade(config, "head")
    engine = create_engine(url)
    assert set(inspect(engine).get_table_names()) == EXPECTED_TABLES
    assert "ix_receipts_user_date" in {
        value["name"] for value in inspect(engine).get_indexes("receipts")
    }

    command.downgrade(config, "base")
    assert inspect(engine).get_table_names() == ["alembic_version"]

    command.upgrade(config, "head")
    assert set(inspect(engine).get_table_names()) == EXPECTED_TABLES
    engine.dispose()
