from __future__ import annotations

import pytest

import app as api
from test_support import isolated_client


def receipt(receipt_id: str = "receipt-1", *, total: int = 250) -> dict:
    return {
        "id": receipt_id, "store_name": "測試商店", "address": "台北市",
        "purchased_at": "2026-10-12T12:30:00+08:00", "total": total,
        "category": "shopping",
        "items": [{"name": "商品", "quantity": 1, "price": total}],
        "receipt_number": "AB12345678", "raw_text": "測試 OCR 原文",
        "latitude": 25.0324, "longitude": 121.5199,
    }


def register(client, email: str = "test@example.com", name: str = "測試使用者"):
    response = client.post("/auth/register", json={
        "name": name, "email": email, "password": "correct-password",
    })
    assert response.status_code == 201
    return response.json()


def test_production_requires_an_explicit_auth_secret(tmp_path):
    with pytest.raises(RuntimeError, match="RECEIPT_TRAIL_AUTH_SECRET"):
        api.load_auth_secret(environment="production", configured=None,
                             secret_path=tmp_path / ".auth-secret")


def test_register_login_refresh_logout_and_receipt_round_trip(tmp_path):
    with isolated_client(tmp_path / "auth.db") as (client, _database):
        session = register(client)
        authorization = {"Authorization": f"Bearer {session['access_token']}"}
        assert client.get("/auth/me", headers=authorization).json()["name"] == "測試使用者"

        saved = client.post("/receipts", json=receipt(), headers={
            **authorization, "Idempotency-Key": "upsert-1",
        })
        assert saved.status_code == 201
        assert saved.json()["period"] == "11510"
        assert client.get("/receipts", headers=authorization).json()[0]["raw_text"] is None

        refreshed = client.post("/auth/refresh", json={
            "refresh_token": session["refresh_token"],
        })
        assert refreshed.status_code == 200
        assert client.post("/auth/refresh", json={
            "refresh_token": session["refresh_token"],
        }).status_code == 401
        next_refresh = refreshed.json()["refresh_token"]
        assert client.post("/auth/logout", json={"refresh_token": next_refresh}).status_code == 204
        assert client.post("/auth/refresh", json={"refresh_token": next_refresh}).status_code == 401
        assert client.post("/auth/login", json={
            "email": "TEST@example.com", "password": "correct-password",
        }).status_code == 200


def test_duplicate_wrong_password_and_amount_validation(tmp_path):
    with isolated_client(tmp_path / "validation.db") as (client, _database):
        register(client, "duplicate@example.com")
        duplicate = client.post("/auth/register", json={
            "name": "使用者", "email": "DUPLICATE@example.com",
            "password": "correct-password",
        })
        assert duplicate.status_code == 409
        assert client.post("/auth/login", json={
            "email": "duplicate@example.com", "password": "wrong-password",
        }).status_code == 401

        session = client.post("/auth/login", json={
            "email": "duplicate@example.com", "password": "correct-password",
        }).json()
        invalid = {**receipt("bad"), "subtotal": 250, "discount": 40, "total": 200}
        assert client.post("/receipts", json=invalid, headers={
            "Authorization": f"Bearer {session['access_token']}",
            "Idempotency-Key": "invalid",
        }).status_code == 422


def test_idempotency_tombstones_bulk_delete_and_user_isolation(tmp_path):
    with isolated_client(tmp_path / "sync.db") as (client, _database):
        user_a, user_b = register(client, "a@example.com"), register(client, "b@example.com")
        auth_a = {"Authorization": f"Bearer {user_a['access_token']}"}
        auth_b = {"Authorization": f"Bearer {user_b['access_token']}"}
        payload = receipt("shared")
        first = client.post("/receipts", json=payload, headers={
            **auth_a, "Idempotency-Key": "a-save",
        })
        replay = client.post("/receipts", json={**payload, "store_name": "不應覆蓋"},
                             headers={**auth_a, "Idempotency-Key": "a-save"})
        assert first.status_code == replay.status_code == 201
        assert client.get("/receipts", headers=auth_a).json()[0]["store_name"] == "測試商店"
        assert client.get("/receipts", headers=auth_b).json() == []

        delete_headers = {**auth_a, "Idempotency-Key": "a-delete"}
        assert client.delete("/receipts/shared", headers=delete_headers).status_code == 204
        assert client.delete("/receipts/shared", headers=delete_headers).status_code == 204
        assert client.post("/receipts", json=payload, headers={
            **auth_a, "Idempotency-Key": "stale",
        }).status_code == 409

        client.post("/receipts", json=receipt("b-receipt"), headers={
            **auth_b, "Idempotency-Key": "b-save",
        })
        reset = {**auth_b, "Idempotency-Key": "b-reset"}
        assert client.delete("/receipts", headers=reset).status_code == 204
        assert client.delete("/receipts", headers=reset).status_code == 204
        assert client.get("/receipts", headers=auth_b).json() == []


def test_invoice_period_uses_taipei_calendar_at_boundaries():
    october = api.ReceiptPayload(
        id="boundary", store_name="跨期商店",
        purchased_at="2026-10-31T16:30:00Z", subtotal=100, discount=0,
        total=100, period="11512", category="food", items=[],
    )
    new_year = api.ReceiptPayload(
        id="new-year", store_name="跨年商店",
        purchased_at="2026-12-31T16:30:00Z", subtotal=100, discount=0,
        total=100, period="11602", category="food", items=[],
    )
    assert october.period == "11512"
    assert new_year.period == "11602"
