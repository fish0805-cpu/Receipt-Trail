from __future__ import annotations

from datetime import UTC, datetime, timedelta
from pathlib import Path

import pytest
from sqlalchemy.dialects import postgresql

from receipt_trail_api.database import Database
from receipt_trail_api.domain import RefreshTokenRecord
from receipt_trail_api.errors import (
    DuplicateEmailError,
    RecordNotFoundError,
    RepositoryConflictError,
)
from receipt_trail_api.repositories.auth import AuthRepository, _consume_token_statement
from receipt_trail_api.tables import metadata


@pytest.fixture
def repository(tmp_path: Path) -> AuthRepository:
    database = Database(f"sqlite+pysqlite:///{(tmp_path / 'auth.db').as_posix()}")
    metadata.create_all(database.engine)
    try:
        yield AuthRepository(database)
    finally:
        database.dispose()


def create_user(repository: AuthRepository, email: str = "person@example.test"):
    return repository.create_user(
        name="Person",
        email=email,
        password_hash="password-hash",
        created_at=datetime(2026, 10, 15, tzinfo=UTC),
    )


def token(token_hash: str, user_id: int, *, expired: bool = False):
    now = datetime(2026, 10, 15, tzinfo=UTC)
    return RefreshTokenRecord(
        token_hash=token_hash,
        user_id=user_id,
        expires_at=now - timedelta(seconds=1) if expired else now + timedelta(days=30),
        revoked_at=None,
    )


def test_email_lookup_is_normalized(repository: AuthRepository) -> None:
    created = create_user(repository, "  Person@Example.TEST ")

    found = repository.get_user_by_email("PERSON@example.test")

    assert found == created
    assert found.email == "person@example.test"


def test_duplicate_email_uses_domain_error(repository: AuthRepository) -> None:
    create_user(repository)

    with pytest.raises(DuplicateEmailError):
        create_user(repository, "PERSON@EXAMPLE.TEST")


def test_refresh_token_is_consumed_once_and_rotated(repository: AuthRepository) -> None:
    user = create_user(repository)
    old = token("old", user.id)
    replacement = token("replacement", user.id)
    repository.store_refresh_token(old)

    consumed = repository.consume_refresh_token(
        "old",
        now=datetime(2026, 10, 15, tzinfo=UTC),
        replacement=replacement,
    )

    assert consumed.token_hash == "old"
    with pytest.raises(RecordNotFoundError):
        repository.consume_refresh_token(
            "old",
            now=datetime(2026, 10, 15, tzinfo=UTC),
            replacement=token("unused", user.id),
        )
    assert repository.consume_refresh_token(
        "replacement",
        now=datetime(2026, 10, 15, tzinfo=UTC),
        replacement=token("next", user.id),
    ).user_id == user.id


def test_revoked_and_expired_tokens_are_rejected(repository: AuthRepository) -> None:
    user = create_user(repository)
    now = datetime(2026, 10, 15, tzinfo=UTC)
    repository.store_refresh_token(token("revoked", user.id))
    repository.revoke_refresh_token("revoked", revoked_at=now)
    repository.store_refresh_token(token("expired", user.id, expired=True))

    for token_hash in ("revoked", "expired"):
        with pytest.raises(RecordNotFoundError):
            repository.consume_refresh_token(
                token_hash,
                now=now,
                replacement=token(f"new-{token_hash}", user.id),
            )


def test_failed_rotation_rolls_back_revocation(repository: AuthRepository) -> None:
    user = create_user(repository)
    now = datetime(2026, 10, 15, tzinfo=UTC)
    repository.store_refresh_token(token("old", user.id))
    repository.store_refresh_token(token("already-exists", user.id))

    with pytest.raises(RepositoryConflictError):
        repository.consume_refresh_token(
            "old",
            now=now,
            replacement=token("already-exists", user.id),
        )

    assert repository.consume_refresh_token(
        "old",
        now=now,
        replacement=token("successful-replacement", user.id),
    ).token_hash == "old"


def test_refresh_consumption_is_a_single_conditional_postgres_update() -> None:
    now = datetime(2026, 10, 15, tzinfo=UTC)
    compiled = str(
        _consume_token_statement("old", now).compile(
            dialect=postgresql.dialect(),
            compile_kwargs={"literal_binds": True},
        )
    ).lower()

    assert "revoked_at is null" in compiled
    assert "expires_at >" in compiled
    assert "returning" in compiled
