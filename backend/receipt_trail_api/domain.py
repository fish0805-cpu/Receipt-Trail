from __future__ import annotations

from dataclasses import dataclass
from datetime import date, datetime


@dataclass(frozen=True, slots=True)
class UserRecord:
    id: int
    name: str
    email: str
    password_hash: str
    created_at: datetime


@dataclass(frozen=True, slots=True)
class RefreshTokenRecord:
    token_hash: str
    user_id: int
    expires_at: datetime
    revoked_at: datetime | None


@dataclass(frozen=True, slots=True)
class PrizeSnapshotRecord:
    term: str
    special_prize: str
    grand_prize: str
    first_prizes: tuple[str, ...]
    additional_sixth_prizes: tuple[str, ...]
    prize_amounts: tuple[tuple[str, int], ...]
    draw_date: date
    claim_start_date: date
    claim_end_date: date
    source_url: str
    published_at: datetime
    updated_at: datetime
    checksum: str


@dataclass(frozen=True, slots=True)
class ReceiptRecord:
    id: str
    store_name: str
    address: str
    purchased_at: datetime
    total: int
    subtotal: int | None
    discount: int
    category: str
    items_json: str
    receipt_number: str
    seller_tax_id: str | None
    period: str | None
    raw_text: str | None
    latitude: float | None
    longitude: float | None
    updated_at: datetime


@dataclass(frozen=True, slots=True)
class SyncOperationRecord:
    user_id: int
    operation_id: str
    kind: str
    receipt_id: str
    completed_at: datetime
