# ---------- Builder ----------
FROM python:3.12-slim AS builder

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# Install dependencies (without project)
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project --no-editable

# Copy source
COPY . /app

# Install project into venv
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-editable

# ---------- Test ----------
FROM builder AS test

ENV PATH="/app/.venv/bin:$PATH"

# ---------- Runtime ----------
FROM python:3.12-slim AS runtime

# Create non-root user
RUN addgroup --system app && adduser --system --ingroup app app

WORKDIR /app

# Copy virtual environment
COPY --from=builder --chown=app:app /app/.venv /app/.venv

# Copy application source
COPY --from=builder --chown=app:app /app/src /app/src
COPY --from=builder --chown=app:app /app/pyproject.toml /app/pyproject.toml

ENV PATH="/app/.venv/bin:$PATH"

USER app

EXPOSE 8070

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8070"]