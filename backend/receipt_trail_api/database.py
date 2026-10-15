from __future__ import annotations

from collections.abc import Iterator
from contextlib import contextmanager
from typing import Any

from sqlalchemy import create_engine, event, text
from sqlalchemy.engine import Engine, make_url
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session, sessionmaker

from receipt_trail_api.config import normalize_database_url


def _snapshot_isolation_level(backend_name: str) -> str | None:
    return "REPEATABLE READ" if backend_name == "postgresql" else None


class Database:
    def __init__(self, url: str) -> None:
        url = normalize_database_url(url)
        backend_name = make_url(url).get_backend_name()
        engine_options: dict[str, Any] = {"pool_pre_ping": True}
        if backend_name == "postgresql":
            engine_options.update(
                pool_size=5,
                max_overflow=2,
                pool_timeout=10,
                pool_recycle=300,
            )

        self._engine = create_engine(url, **engine_options)
        if backend_name == "sqlite":
            event.listen(self._engine, "connect", self._enable_sqlite_foreign_keys)
        self._sessions = sessionmaker(bind=self._engine, expire_on_commit=False)

    @staticmethod
    def _enable_sqlite_foreign_keys(
        dbapi_connection: Any,
        _connection_record: Any,
    ) -> None:
        cursor = dbapi_connection.cursor()
        try:
            cursor.execute("PRAGMA foreign_keys=ON")
        finally:
            cursor.close()

    @property
    def engine(self) -> Engine:
        return self._engine

    @contextmanager
    def transaction(self) -> Iterator[Session]:
        session = self._sessions()
        try:
            with session.begin():
                yield session
        finally:
            session.close()

    @contextmanager
    def read_snapshot(self) -> Iterator[Session]:
        isolation_level = _snapshot_isolation_level(self._engine.dialect.name)
        if isolation_level is None:
            with self.transaction() as session:
                yield session
            return

        connection = self._engine.connect().execution_options(
            isolation_level=isolation_level
        )
        transaction = connection.begin()
        session = Session(bind=connection, expire_on_commit=False)
        try:
            connection.execute(text("SET TRANSACTION READ ONLY"))
            yield session
        finally:
            session.close()
            if transaction.is_active:
                transaction.rollback()
            connection.close()

    def healthcheck(self) -> bool:
        try:
            with self._engine.connect() as connection:
                connection.execute(text("SELECT 1"))
            return True
        except SQLAlchemyError:
            return False

    def dispose(self) -> None:
        self._engine.dispose()
