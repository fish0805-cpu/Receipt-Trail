from sqlalchemy import func, select

from receipt_trail_api.tables import prize_number_snapshots
from test_support import isolated_client


def payload() -> dict:
    return {
        "term": "11510", "special_prize": "11112222",
        "grand_prize": "33334444",
        "first_prizes": ["12345678", "87654321", "13572468"],
        "additional_sixth_prizes": ["999"],
        "prize_amounts": {
            "special": 10000000, "grand": 2000000, "first": 200000,
            "second": 40000, "third": 10000, "fourth": 4000,
            "fifth": 1000, "sixth": 200, "additionalSixth": 200,
        },
        "draw_date": "2026-11-25", "claim_start_date": "2026-12-06",
        "claim_end_date": "2027-03-05",
        "source_url": "https://www.etax.nat.gov.tw/example",
        "published_at": "2026-11-25T12:00:00Z",
    }


def test_admin_import_is_protected_idempotent_and_publicly_readable(tmp_path):
    with isolated_client(tmp_path / "prizes.db") as (client, database):
        assert client.get("/prize-numbers/11510").status_code == 404
        assert client.put("/admin/prize-numbers/11510", json=payload()).status_code == 401
        headers = {"X-Admin-Key": "test-admin-secret"}
        first = client.put("/admin/prize-numbers/11510", json=payload(), headers=headers)
        repeated = client.put("/admin/prize-numbers/11510", json=payload(), headers=headers)
        assert first.status_code == 201
        assert repeated.status_code == 200
        assert repeated.json()["checksum"] == first.json()["checksum"]
        public = client.get("/prize-numbers/11510")
        assert public.status_code == 200
        assert public.json()["prize_amounts"]["first"] == 200000
        with database.transaction() as session:
            count = session.scalar(select(func.count()).select_from(prize_number_snapshots))
        assert count == 1


def test_import_rejects_invalid_numbers_dates_and_term(tmp_path):
    with isolated_client(tmp_path / "invalid.db") as (client, _database):
        headers = {"X-Admin-Key": "test-admin-secret"}
        cases = [
            {**payload(), "special_prize": "123"},
            {**payload(), "draw_date": "2026-09-25"},
            {**payload(), "grand_prize": "11112222"},
            {**payload(), "claim_start_date": "2027-04-01"},
        ]
        for invalid in cases:
            assert client.put("/admin/prize-numbers/11510", json=invalid,
                              headers=headers).status_code == 422
        assert client.put("/admin/prize-numbers/11509",
                          json={**payload(), "term": "11509"},
                          headers=headers).status_code == 422
