from __future__ import annotations

from sqlalchemy import (
    CheckConstraint,
    Column,
    Float,
    ForeignKey,
    Index,
    Integer,
    MetaData,
    PrimaryKeyConstraint,
    Table,
    Text,
    UniqueConstraint,
    func,
)


metadata = MetaData()

users = Table(
    "users",
    metadata,
    Column("id", Integer, primary_key=True, autoincrement=True),
    Column("name", Text, nullable=False),
    Column("email", Text, nullable=False),
    Column("password_hash", Text, nullable=False),
    Column("created_at", Text, nullable=False),
    UniqueConstraint("email", name="uq_users_email"),
)
Index("uq_users_email_lower", func.lower(users.c.email), unique=True)

refresh_tokens = Table(
    "refresh_tokens",
    metadata,
    Column("token_hash", Text, primary_key=True),
    Column(
        "user_id",
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    ),
    Column("expires_at", Text, nullable=False),
    Column("revoked_at", Text),
)
Index("ix_refresh_tokens_user_id", refresh_tokens.c.user_id)

receipts = Table(
    "receipts",
    metadata,
    Column(
        "user_id",
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    ),
    Column("id", Text, nullable=False),
    Column("store_name", Text, nullable=False),
    Column("address", Text, nullable=False),
    Column("purchased_at", Text, nullable=False),
    Column("total", Integer, nullable=False),
    Column("subtotal", Integer),
    Column("discount", Integer, nullable=False, server_default="0"),
    Column("category", Text, nullable=False),
    Column("items_json", Text, nullable=False),
    Column("receipt_number", Text, nullable=False),
    Column("seller_tax_id", Text),
    Column("period", Text),
    Column("raw_text", Text),
    Column("latitude", Float),
    Column("longitude", Float),
    Column("updated_at", Text, nullable=False),
    PrimaryKeyConstraint("user_id", "id", name="pk_receipts"),
)
Index("ix_receipts_user_date", receipts.c.user_id, receipts.c.purchased_at.desc())

sync_operations = Table(
    "sync_operations",
    metadata,
    Column(
        "user_id",
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    ),
    Column("operation_id", Text, nullable=False),
    Column("kind", Text, nullable=False),
    Column("receipt_id", Text, nullable=False),
    Column("completed_at", Text, nullable=False),
    PrimaryKeyConstraint("user_id", "operation_id", name="pk_sync_operations"),
    CheckConstraint("kind IN ('upsert', 'delete')", name="ck_sync_operation_kind"),
)

receipt_tombstones = Table(
    "receipt_tombstones",
    metadata,
    Column(
        "user_id",
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    ),
    Column("receipt_id", Text, nullable=False),
    Column("deleted_at", Text, nullable=False),
    PrimaryKeyConstraint("user_id", "receipt_id", name="pk_receipt_tombstones"),
)

prize_number_snapshots = Table(
    "prize_number_snapshots",
    metadata,
    Column("term", Text, primary_key=True),
    Column("special_prize", Text, nullable=False),
    Column("grand_prize", Text, nullable=False),
    Column("first_prizes_json", Text, nullable=False),
    Column("additional_sixth_prizes_json", Text, nullable=False),
    Column("prize_amounts_json", Text, nullable=False),
    Column("draw_date", Text, nullable=False),
    Column("claim_start_date", Text, nullable=False),
    Column("claim_end_date", Text, nullable=False),
    Column("source_url", Text, nullable=False),
    Column("published_at", Text, nullable=False),
    Column("updated_at", Text, nullable=False),
    Column("checksum", Text, nullable=False),
)
