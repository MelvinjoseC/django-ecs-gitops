.PHONY: help install-dev lint ruff format test coverage docker-build docker-up docker-down tf-fmt tf-validate smoke-test clean

help:
	@echo "Available commands:"
	@echo "  make install-dev   Install development dependencies"
	@echo "  make lint          Run flake8 linter on app code"
	@echo "  make ruff          Run fast Ruff linter"
	@echo "  make format        Format code using black and ruff"
	@echo "  make test          Run test suite with pytest"
	@echo "  make coverage      Run tests and generate coverage report"
	@echo "  make docker-build  Build production Docker image"
	@echo "  make docker-up     Start local stack with docker-compose"
	@echo "  make docker-down   Stop local docker-compose stack"
	@echo "  make tf-fmt        Format terraform files"
	@echo "  make tf-validate   Validate terraform configuration"
	@echo "  make smoke-test    Run local HTTP health probe verification"
	@echo "  make clean         Clean build and cache artifacts"

install-dev:
	pip install -r requirements-dev.txt

lint:
	flake8 app/

ruff:
	ruff check app/

format:
	black app/
	ruff check --fix app/ || true

test:
	pytest

coverage:
	coverage run -m pytest
	coverage report -m
	coverage xml

docker-build:
	docker build -t django-ecs-gitops:latest .

docker-up:
	docker compose up -d

docker-down:
	docker compose down -v

tf-fmt:
	cd terraform && terraform fmt -recursive

tf-validate:
	cd terraform && terraform init -backend=false && terraform validate

smoke-test:
	curl -f http://localhost:8000/api/health/live/ && echo " Live probe OK"
	curl -f http://localhost:8000/api/health/ready/ && echo " Ready probe OK"

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache .coverage coverage.xml htmlcov staticfiles
