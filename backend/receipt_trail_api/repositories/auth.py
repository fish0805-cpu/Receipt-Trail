from __future__ import annotations

from datetime import datetime

from sqlalchemy import insert, select, update
from sqlalchemy.exc import IntegrityError

from receipt_trail_api.database import Database
from receipt_trail_api.domain import RefreshTokenRecord, UserRecord
from receipt_trail_api.errors import (
    DuplicateEmailError,
    RecordNotFoundError,
    RepositoryConflictError,
)
from receipt_trail_api.tables import refresh_tokens, users


def _normalize_email(value: str) -> str:
    return value.strip().lower()


def _user_from_row(row) -> UserRecord:
    values = row._mapping
    return UserRecord(
        id=values["id"],
        name=values["name"],
        email=values["email"],
        password_hash=values["password_hash"],
        created_at=datetime.fromisoformat(values["created_at"]),
    )


def _token_from_row(row) -> RefreshTokenRecord:
    values = row._mapping
    revoked_at = values["revoked_at"]
    return RefreshTokenRecord(
        token_hash=values["token_hash"],
        user_id=values["user_id"],
        expires_at=datetime.fromisoformat(values["expires_at"]),
        revoked_at=datetime.fromisoformat(revoked_at) if revoked_at else None,
    )


def _consume_token_statement(token_hash: str, now: datetime):
    return (
        update(refresh_tokens)
        .where(
            refresh_tokens.c.token_hash == token_hash,
            refresh_tokens.c.revoked_at.is_(None),
            refresh_tokens.c.expires_at > now.isoformat(),
        )
        .values(revoked_at=now.isoformat())
        .returning(
            refresh_tokens.c.token_hash,
            refresh_tokens.c.user_id,
            refresh_tokens.c.expires_at,
        )
    )


class AuthRepository:
    def __init__(self, database: Database) -> None:
        self._database = database

    def create_user(
        self,
        *,
        name: str,
        email: str,
        password_hash: str,
        created_at: datetime,
    ) -> UserRecord:
        normalized_email = _normalize_email(email)
        try:
            with self._database.transaction() as session:
                result = session.execute(
                    insert(users).values(
                        name=name,
                        email=normalized_email,
                        password_hash=password_hash,
                        created_at=created_at.isoformat(),
                    )
                )
                user_id = int(result.inserted_primary_key[0])
                row = session.execute(
                    select(users).where(users.c.id == user_id)
                ).one()
                return _user_from_row(row)
        except IntegrityError as error:
            raise DuplicateEmailError("email already registered") from error

    def get_user_by_id(self, user_id: int) -> UserRecord | None:
        with self._database.transaction() as session:
            row = session.execute(
                select(users).where(users.c.id == user_id)
            ).one_or_none()
        return _user_from_row(row) if row else None

    def get_user_by_email(self, email: str) -> UserRecord | None:
        normalized_email = _normalize_email(email)
        with self._database.transaction() as session:
            row = session.execute(
                select(users).where(users.c.email == normalized_email)
            ).one_or_none()
        return _user_from_row(row) if row else None

    def store_refresh_token(self, record: RefreshTokenRecord) -> None:
        try:
            with self._database.transaction() as session:
                session.execute(
                    insert(refresh_tokens).values(
                        token_hash=record.token_hash,
                        user_id=record.user_id,
                        expires_at=record.expires_at.isoformat(),
                        revoked_at=(
                            record.revoked_at.isoformat()
                            if record.revoked_at is not None
                            else None
                        ),
                    )
                )
        except IntegrityError as error:
            raise RepositoryConflictError("refresh token conflict") from error

    def consume_refresh_token(
        self,
        token_hash: str,
        *,
        now: datetime,
        replacement: RefreshTokenRecord,
    ) -> RefreshTokenRecord:
        try:
            with self._database.transaction() as session:
                row = session.execute(
                    _consume_token_statement(token_hash, now)
                ).one_or_none()
                if row is None:
                    raise RecordNotFoundError("refresh token unavailable")
                values = row._mapping
                current = RefreshTokenRecord(
                    token_hash=values["token_hash"],
                    user_id=values["user_id"],
                    expires_at=datetime.fromisoformat(values["expires_at"]),
                    revoked_at=None,
                )
                session.execute(
                    insert(refresh_tokens).values(
                        token_hash=replacement.token_hash,
                        user_id=current.user_id,
                        expires_at=replacement.expires_at.isoformat(),
                        revoked_at=None,
                    )
                )
                return current
        except IntegrityError as error:
            raise RepositoryConflictError("refresh token conflict") from error

    def revoke_refresh_token(self, token_hash: str, *, revoked_at: datetime) -> bool:
        with self._database.transaction() as session:
            result = session.execute(
                update(refresh_tokens)
                .where(refresh_tokens.c.token_hash == token_hash)
                .values(revoked_at=revoked_at.isoformat())
            )
            return bool(result.rowcount)
