from __future__ import annotations

import re
from datetime import date, datetime, timedelta, timezone
from typing import Self

from pydantic import BaseModel, Field, field_validator, model_validator


TAIPEI_TIME_ZONE = timezone(timedelta(hours=8))


def invoice_period(value: datetime) -> str:
    local = value.replace(tzinfo=TAIPEI_TIME_ZONE) if value.tzinfo is None else value.astimezone(TAIPEI_TIME_ZONE)
    end_month = local.month if local.month % 2 == 0 else local.month + 1
    return f"{local.year - 1911:03d}{end_month:02d}"


class UserResponse(BaseModel):
    id: int
    name: str
    email: str


class RegisterRequest(BaseModel):
    name: str = Field(min_length=1, max_length=80)
    email: str = Field(min_length=3, max_length=254)
    password: str = Field(min_length=8, max_length=128)


class LoginRequest(BaseModel):
    email: str
    password: str


class RefreshRequest(BaseModel):
    refresh_token: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int = 900
    user: UserResponse


class ReceiptItemPayload(BaseModel):
    name: str
    quantity: int = Field(default=1, ge=1)
    price: int = Field(ge=0)


class ReceiptPayload(BaseModel):
    id: str = Field(min_length=1, max_length=100)
    store_name: str = Field(min_length=1, max_length=200)
    address: str = Field(default="未填寫地址", max_length=500)
    purchased_at: datetime
    total: int = Field(ge=0)
    subtotal: int | None = Field(default=None, ge=0)
    discount: int = Field(default=0, ge=0)
    category: str
    items: list[ReceiptItemPayload]
    receipt_number: str = Field(default="未填寫", max_length=100)
    seller_tax_id: str | None = Field(default=None, max_length=8)
    period: str | None = None
    raw_text: str | None = None
    latitude: float | None = None
    longitude: float | None = None

    @model_validator(mode="after")
    def validate_invoice_values(self) -> Self:
        if self.subtotal is None:
            self.subtotal = self.total
        if self.subtotal - self.discount != self.total:
            raise ValueError("商品小計扣除折扣後必須等於實付金額")
        expected = invoice_period(self.purchased_at)
        if self.period is None:
            self.period = expected
        elif self.period != expected:
            raise ValueError("發票期別與消費日期不一致")
        if self.seller_tax_id is not None:
            self.seller_tax_id = self.seller_tax_id.strip() or None
        return self


class PrizeNumberImport(BaseModel):
    term: str
    special_prize: str
    grand_prize: str
    first_prizes: list[str] = Field(min_length=1)
    additional_sixth_prizes: list[str] = Field(default_factory=list)
    prize_amounts: dict[str, int]
    draw_date: date
    claim_start_date: date
    claim_end_date: date
    source_url: str = Field(min_length=1, max_length=1000)
    published_at: datetime

    @field_validator("term")
    @classmethod
    def validate_term(cls, value: str) -> str:
        if not re.fullmatch(r"\d{5}", value):
            raise ValueError("發票期別格式不正確")
        if int(value[:3]) < 1 or int(value[-2:]) not in {2, 4, 6, 8, 10, 12}:
            raise ValueError("發票期別月份必須是雙數月")
        return value

    @field_validator("special_prize", "grand_prize")
    @classmethod
    def validate_single_number(cls, value: str) -> str:
        if not re.fullmatch(r"\d{8}", value):
            raise ValueError("獎號必須是 8 位數字")
        return value

    @field_validator("first_prizes")
    @classmethod
    def validate_first_prizes(cls, value: list[str]) -> list[str]:
        if len(value) != len(set(value)) or any(not re.fullmatch(r"\d{8}", number) for number in value):
            raise ValueError("頭獎號碼必須是不重複的 8 位數字")
        return value

    @field_validator("additional_sixth_prizes")
    @classmethod
    def validate_additional_sixth(cls, value: list[str]) -> list[str]:
        if len(value) != len(set(value)) or any(not re.fullmatch(r"\d{3}", number) for number in value):
            raise ValueError("增開六獎必須是不重複的 3 位數字")
        return value

    @field_validator("prize_amounts")
    @classmethod
    def validate_prize_amounts(cls, value: dict[str, int]) -> dict[str, int]:
        expected = {"special", "grand", "first", "second", "third", "fourth", "fifth", "sixth", "additionalSixth"}
        if set(value) != expected or any(amount <= 0 for amount in value.values()):
            raise ValueError("必須提供所有獎別的正整數獎金")
        return value

    @model_validator(mode="after")
    def validate_dates(self) -> Self:
        if not self.draw_date <= self.claim_start_date <= self.claim_end_date:
            raise ValueError("開獎與領獎日期順序不正確")
        year, end_month = int(self.term[:3]) + 1911, int(self.term[3:])
        expected_draw = date(year + 1, 1, 25) if end_month == 12 else date(year, end_month + 1, 25)
        if self.draw_date != expected_draw:
            raise ValueError("開獎日與發票期別不一致")
        if not timedelta(0) <= self.claim_start_date - self.draw_date <= timedelta(days=45):
            raise ValueError("領獎起日不在此期合理範圍")
        if not timedelta(days=60) <= self.claim_end_date - self.claim_start_date <= timedelta(days=120):
            raise ValueError("領獎期限不在此期合理範圍")
        full_prizes = [self.special_prize, self.grand_prize, *self.first_prizes]
        if len(full_prizes) != len(set(full_prizes)):
            raise ValueError("各獎別的完整獎號不得重複")
        if not self.source_url.startswith("https://"):
            raise ValueError("資料來源必須使用 HTTPS")
        return self


class PrizeNumberResponse(PrizeNumberImport):
    updated_at: datetime
    checksum: str
