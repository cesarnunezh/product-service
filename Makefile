.DEFAULT_GOAL := help

help:
	@echo "Available targets:"
	@echo "  setup   - install dependencies"
	@echo "  lint    - run ruff"
	@echo "  test    - run pytest"
	@echo "  run     - run uvicorn"
	@echo "  build   - build docker image"

setup:
	pip install --no-cache-dir uv
	uv pip install --system fastapi uvicorn ruff pytest httpx

lint:
	ruff check .

test:
	pytest

run:
	uvicorn src.main:app --reload

build:
	docker build -t product-product-service:local .
