.DEFAULT_GOAL := help

help:
	@echo "Available targets:"
	@echo "  setup   - build test docker image"
	@echo "  lint    - run ruff"
	@echo "  test    - run pytest"
	@echo "  scan    - run security scan placeholder"
	@echo "  run     - run uvicorn"
	@echo "  build   - build docker image"

setup:
	-docker rmi -f products-api:test
	docker build --target test -t products-api:test .

lint: setup
	docker run --rm products-api:test ruff format --check .
	docker run --rm products-api:test ruff check .

test: setup
	docker run --rm products-api:test uv run -m pytest

scan:
	@echo "No security scanner configured yet for product-service"

run:
	uvicorn src.main:app --reload

build:
	docker build -t products-api:ci-local .
