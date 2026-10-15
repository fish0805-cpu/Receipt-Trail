FROM ghcr.io/astral-sh/uv:0.8.17-python3.12-bookworm-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_CACHE_DIR=/tmp/uv-cache

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

COPY alembic.ini app.py ./
COPY alembic ./alembic
COPY receipt_trail_api ./receipt_trail_api

RUN useradd --create-home --uid 10001 appuser

USER appuser

CMD ["sh", "-c", ".venv/bin/alembic upgrade head && exec .venv/bin/uvicorn app:app --host 0.0.0.0 --port ${PORT} --workers 1"]
