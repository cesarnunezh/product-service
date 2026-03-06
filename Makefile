.DEFAULT_GOAL := help

help:
	@echo "Available targets:"
	@echo "  setup   - install dependencies"
	@echo "  lint    - run ruff"
	@echo "  test    - run pytest"
	@echo "  scan    - run security scan placeholder"
	@echo "  run     - run uvicorn"
	@echo "  build   - build docker image"

setup:
	pip install --no-cache-dir uv
	uv pip install --system fastapi uvicorn ruff pytest httpx

lint:
	ruff check .

test:
	pytest

scan:
	@echo "No security scanner configured yet for product-service"

run:
	uvicorn src.main:app --reload

build:
	docker build -t products-api:ci-local .
