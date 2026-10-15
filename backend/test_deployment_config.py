from pathlib import Path

import yaml


ROOT = Path(__file__).resolve().parent.parent
BACKEND = ROOT / "backend"


def test_docker_image_is_locked_non_root_and_binds_render_port() -> None:
    dockerfile = (BACKEND / "Dockerfile").read_text(encoding="utf-8")

    assert "python3.12" in dockerfile
    assert "uv sync --frozen --no-dev" in dockerfile
    assert "USER appuser" in dockerfile
    assert "alembic upgrade head" in dockerfile
    assert "uvicorn app:app" in dockerfile
    assert "--host 0.0.0.0" in dockerfile
    assert "--port ${PORT}" in dockerfile
    assert "--workers 1" in dockerfile
    assert ".venv/bin/alembic upgrade head" in dockerfile
    assert ".venv/bin/uvicorn app:app" in dockerfile
    assert "CMD [\"sh\", \"-c\", \"uv run" not in dockerfile
    assert "chown -R" not in dockerfile
    assert "receipt_trail.db" not in dockerfile


def test_docker_context_excludes_local_data_secrets_and_tests() -> None:
    patterns = {
        line.strip()
        for line in (BACKEND / ".dockerignore").read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    }

    assert {
        ".venv", ".env*", ".auth-secret", "*.db", "*.db-*",
        "backups", "exports", "test_*.py", "__pycache__",
    } <= patterns


def test_render_blueprint_is_free_and_contains_no_secret_values() -> None:
    blueprint = yaml.safe_load((ROOT / "render.yaml").read_text(encoding="utf-8"))
    assert len(blueprint["services"]) == 1
    service = blueprint["services"][0]
    assert service["name"] == "receipt-trail-api"
    assert service["plan"] == "free"
    assert service["rootDir"] == "backend"
    assert service["healthCheckPath"] == "/health"
    variables = {item["key"]: item for item in service["envVars"]}
    assert variables["RECEIPT_TRAIL_ENV"]["value"] == "production"
    for secret in (
        "DATABASE_URL", "RECEIPT_TRAIL_AUTH_SECRET",
        "RECEIPT_TRAIL_PRIZE_ADMIN_KEY",
    ):
        assert variables[secret] == {"key": secret, "sync": False}
    serialized = (ROOT / "render.yaml").read_text(encoding="utf-8").lower()
    assert "postgres://" not in serialized
    assert "change-me" not in serialized
    assert "receipt_trail.db" not in serialized
