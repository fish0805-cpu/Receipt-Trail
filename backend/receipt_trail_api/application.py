from __future__ import annotations

import hashlib
import json
import re
import secrets
from datetime import UTC, datetime, timedelta

import jwt
from fastapi import Depends, FastAPI, Header, HTTPException, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pwdlib import PasswordHash
from sqlalchemy.exc import SQLAlchemyError

from receipt_trail_api.config import Settings
from receipt_trail_api.database import Database
from receipt_trail_api.domain import PrizeSnapshotRecord, ReceiptRecord, RefreshTokenRecord, UserRecord
from receipt_trail_api.errors import DuplicateEmailError, RecordNotFoundError, RepositoryConflictError
from receipt_trail_api.repositories.auth import AuthRepository
from receipt_trail_api.repositories.prizes import PrizeNumberRepository
from receipt_trail_api.repositories.receipts import ReceiptRepository
from receipt_trail_api.schemas import (
    LoginRequest, PrizeNumberImport, PrizeNumberResponse, ReceiptItemPayload,
    ReceiptPayload, RefreshRequest, RegisterRequest, TokenResponse, UserResponse,
)
from receipt_trail_api.tables import metadata


PASSWORD_HASH = PasswordHash.recommended()
EMAIL_PATTERN = re.compile(r"^[^\s@]+@[^\s@]+\.[^\s@]+$")


def _user_response(user: UserRecord) -> UserResponse:
    return UserResponse(id=user.id, name=user.name, email=user.email)


def _token_hash(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def _receipt_payload(value: ReceiptRecord) -> ReceiptPayload:
    return ReceiptPayload(
        id=value.id, store_name=value.store_name, address=value.address,
        purchased_at=value.purchased_at, total=value.total, subtotal=value.subtotal,
        discount=value.discount, category=value.category,
        items=[ReceiptItemPayload(**item) for item in json.loads(value.items_json)],
        receipt_number=value.receipt_number, seller_tax_id=value.seller_tax_id,
        period=value.period, raw_text=None, latitude=value.latitude,
        longitude=value.longitude,
    )


def _receipt_record(value: ReceiptPayload) -> ReceiptRecord:
    return ReceiptRecord(
        id=value.id, store_name=value.store_name, address=value.address,
        purchased_at=value.purchased_at, total=value.total, subtotal=value.subtotal,
        discount=value.discount, category=value.category,
        items_json=json.dumps([item.model_dump() for item in value.items], ensure_ascii=False),
        receipt_number=value.receipt_number, seller_tax_id=value.seller_tax_id,
        period=value.period, raw_text=None, latitude=value.latitude,
        longitude=value.longitude, updated_at=datetime.now(UTC),
    )


def _prize_response(value: PrizeSnapshotRecord) -> PrizeNumberResponse:
    return PrizeNumberResponse(
        term=value.term, special_prize=value.special_prize, grand_prize=value.grand_prize,
        first_prizes=list(value.first_prizes),
        additional_sixth_prizes=list(value.additional_sixth_prizes),
        prize_amounts=dict(value.prize_amounts), draw_date=value.draw_date,
        claim_start_date=value.claim_start_date, claim_end_date=value.claim_end_date,
        source_url=value.source_url, published_at=value.published_at,
        updated_at=value.updated_at, checksum=value.checksum,
    )


def create_app(
    settings: Settings | None = None,
    database: Database | None = None,
) -> FastAPI:
    resolved_settings = settings or Settings.load(__import__("os").environ)
    resolved_database = database or Database(resolved_settings.database_url)
    if resolved_settings.environment != "production":
        metadata.create_all(resolved_database.engine)
    auth_repository = AuthRepository(resolved_database)
    receipt_repository = ReceiptRepository(resolved_database)
    prize_repository = PrizeNumberRepository(resolved_database)
    app = FastAPI(title="Receipt Trail API", version="1.0.0")
    app.add_middleware(
        CORSMiddleware, allow_origins=["*"], allow_credentials=False,
        allow_methods=["*"], allow_headers=["*"],
    )

    @app.exception_handler(SQLAlchemyError)
    async def database_unavailable(_request, _error):
        return JSONResponse(
            status_code=503,
            content={"detail": "雲端服務暫時無法使用，請稍後再試。"},
        )

    def issue_session(user: UserRecord) -> TokenResponse:
        now = datetime.now(UTC)
        access_token = jwt.encode(
            {"sub": str(user.id), "type": "access", "iat": now,
             "exp": now + timedelta(minutes=15)},
            resolved_settings.auth_secret,
            algorithm="HS256",
        )
        refresh_token = secrets.token_urlsafe(48)
        auth_repository.store_refresh_token(RefreshTokenRecord(
            token_hash=_token_hash(refresh_token),
            user_id=user.id,
            expires_at=now + timedelta(days=30),
            revoked_at=None,
        ))
        return TokenResponse(access_token=access_token, refresh_token=refresh_token,
                             user=_user_response(user))

    def access_user(authorization: str | None = Header(default=None)) -> UserRecord:
        if not authorization or not authorization.startswith("Bearer "):
            raise HTTPException(status_code=401, detail="尚未登入")
        try:
            payload = jwt.decode(authorization.removeprefix("Bearer ").strip(),
                                 resolved_settings.auth_secret, algorithms=["HS256"])
            if payload.get("type") != "access":
                raise jwt.InvalidTokenError
            user = auth_repository.get_user_by_id(int(payload["sub"]))
        except (jwt.InvalidTokenError, KeyError, ValueError) as error:
            raise HTTPException(status_code=401, detail="登入憑證已失效") from error
        if user is None:
            raise HTTPException(status_code=401, detail="找不到使用者")
        return user

    @app.get("/health")
    def health() -> dict[str, str]:
        return {"status": "ok"}

    @app.post("/auth/register", response_model=TokenResponse, status_code=201)
    def register(payload: RegisterRequest) -> TokenResponse:
        email = payload.email.strip().lower()
        if not EMAIL_PATTERN.fullmatch(email):
            raise HTTPException(status_code=422, detail="Email 格式不正確")
        try:
            user = auth_repository.create_user(
                name=payload.name.strip(), email=email,
                password_hash=PASSWORD_HASH.hash(payload.password),
                created_at=datetime.now(UTC),
            )
        except DuplicateEmailError as error:
            raise HTTPException(status_code=409, detail="這個 Email 已註冊") from error
        return issue_session(user)

    @app.post("/auth/login", response_model=TokenResponse)
    def login(payload: LoginRequest) -> TokenResponse:
        email = payload.email.strip().lower()
        user = auth_repository.get_user_by_email(email)
        if user is None or not PASSWORD_HASH.verify(payload.password, user.password_hash):
            raise HTTPException(status_code=401, detail="Email 或密碼錯誤")
        return issue_session(user)

    @app.post("/auth/refresh", response_model=TokenResponse)
    def refresh(payload: RefreshRequest) -> TokenResponse:
        now = datetime.now(UTC)
        raw_replacement = secrets.token_urlsafe(48)
        replacement = RefreshTokenRecord(
            token_hash=_token_hash(raw_replacement), user_id=0,
            expires_at=now + timedelta(days=30), revoked_at=None,
        )
        try:
            consumed = auth_repository.consume_refresh_token(
                _token_hash(payload.refresh_token), now=now, replacement=replacement
            )
        except RecordNotFoundError as error:
            raise HTTPException(status_code=401, detail="Refresh Token 已失效") from error
        user = auth_repository.get_user_by_id(consumed.user_id)
        if user is None:
            raise HTTPException(status_code=401, detail="找不到使用者")
        access_token = jwt.encode(
            {"sub": str(user.id), "type": "access", "iat": now,
             "exp": now + timedelta(minutes=15)},
            resolved_settings.auth_secret, algorithm="HS256",
        )
        return TokenResponse(access_token=access_token, refresh_token=raw_replacement,
                             user=_user_response(user))

    @app.post("/auth/logout", status_code=204)
    def logout(payload: RefreshRequest) -> None:
        auth_repository.revoke_refresh_token(
            _token_hash(payload.refresh_token), revoked_at=datetime.now(UTC)
        )

    @app.get("/auth/me", response_model=UserResponse)
    def me(user: UserRecord = Depends(access_user)) -> UserResponse:
        return _user_response(user)

    @app.get("/receipts", response_model=list[ReceiptPayload])
    def list_receipts(user: UserRecord = Depends(access_user)):
        return [_receipt_payload(value) for value in receipt_repository.list_for_user(user.id)]

    def operation_id(value: str) -> str:
        normalized = value.strip()
        if not normalized or len(normalized) > 200:
            raise HTTPException(status_code=422, detail="同步操作識別碼格式不正確")
        return normalized

    def save_for_user(receipt: ReceiptPayload, user: UserRecord, key: str) -> ReceiptPayload:
        try:
            return _receipt_payload(
                receipt_repository.save(user.id, operation_id(key), _receipt_record(receipt))
            )
        except RepositoryConflictError as error:
            raise HTTPException(status_code=409, detail="同步操作識別碼衝突") from error

    @app.post("/receipts", response_model=ReceiptPayload, status_code=201)
    def save_receipt(receipt: ReceiptPayload, user: UserRecord = Depends(access_user),
                     idempotency_key: str = Header(alias="Idempotency-Key")):
        return save_for_user(receipt, user, idempotency_key)

    @app.put("/receipts/{receipt_id}", response_model=ReceiptPayload)
    def update_receipt(receipt_id: str, receipt: ReceiptPayload,
                       user: UserRecord = Depends(access_user),
                       idempotency_key: str = Header(alias="Idempotency-Key")):
        if receipt_id != receipt.id:
            raise HTTPException(status_code=422, detail="發票 ID 不一致")
        return save_for_user(receipt, user, idempotency_key)

    @app.delete("/receipts", status_code=204)
    def delete_all_receipts(user: UserRecord = Depends(access_user),
                            idempotency_key: str = Header(alias="Idempotency-Key")) -> None:
        try:
            receipt_repository.delete_all(user.id, operation_id(idempotency_key))
        except RepositoryConflictError as error:
            raise HTTPException(status_code=409, detail="同步操作識別碼衝突") from error

    @app.delete("/receipts/{receipt_id}", status_code=204)
    def delete_receipt(receipt_id: str, user: UserRecord = Depends(access_user),
                       idempotency_key: str = Header(alias="Idempotency-Key")) -> None:
        try:
            receipt_repository.delete(user.id, operation_id(idempotency_key), receipt_id)
        except RepositoryConflictError as error:
            raise HTTPException(status_code=409, detail="同步操作識別碼衝突") from error

    def require_prize_admin(x_admin_key: str | None = Header(default=None)) -> None:
        expected = resolved_settings.prize_admin_key
        if not expected:
            raise HTTPException(status_code=503, detail="獎號管理金鑰尚未設定")
        if not x_admin_key or not secrets.compare_digest(x_admin_key, expected):
            raise HTTPException(status_code=401, detail="獎號管理權限不足")

    @app.get("/prize-numbers/{term}", response_model=PrizeNumberResponse)
    def get_prize_numbers(term: str) -> PrizeNumberResponse:
        PrizeNumberImport.validate_term(term)
        found = prize_repository.get(term)
        if found is None:
            raise HTTPException(status_code=404, detail="尚未匯入此期官方獎號")
        return _prize_response(found)

    @app.put("/admin/prize-numbers/{term}", response_model=PrizeNumberResponse,
             status_code=201, dependencies=[Depends(require_prize_admin)])
    def import_prize_numbers(term: str, payload: PrizeNumberImport,
                             response: Response) -> PrizeNumberResponse:
        if term != payload.term:
            raise HTTPException(status_code=422, detail="網址與內容的發票期別不一致")
        canonical = json.dumps(payload.model_dump(mode="json"), ensure_ascii=False,
                               separators=(",", ":"), sort_keys=True)
        snapshot = PrizeSnapshotRecord(
            term=payload.term, special_prize=payload.special_prize,
            grand_prize=payload.grand_prize, first_prizes=tuple(payload.first_prizes),
            additional_sixth_prizes=tuple(payload.additional_sixth_prizes),
            prize_amounts=tuple(payload.prize_amounts.items()),
            draw_date=payload.draw_date, claim_start_date=payload.claim_start_date,
            claim_end_date=payload.claim_end_date, source_url=payload.source_url,
            published_at=payload.published_at, updated_at=datetime.now(UTC),
            checksum=hashlib.sha256(canonical.encode("utf-8")).hexdigest(),
        )
        stored, created = prize_repository.upsert(snapshot)
        if not created:
            response.status_code = 200
        return _prize_response(stored)

    return app
