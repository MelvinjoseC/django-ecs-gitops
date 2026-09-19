.PHONY: help install-dev lint format test coverage docker-build docker-up docker-down tf-fmt tf-validate clean

help:
	@echo "Available commands:"
	@echo "  make install-dev   Install development dependencies"
	@echo "  make lint          Run flake8 linter on app code"
	@echo "  make format        Format code using black"
	@echo "  make test          Run test suite with pytest"
	@echo "  make coverage      Run tests and generate coverage report"
	@echo "  make docker-build  Build production Docker image"
	@echo "  make docker-up     Start local stack with docker-compose"
	@echo "  make docker-down   Stop local docker-compose stack"
	@echo "  make tf-fmt        Format terraform files"
	@echo "  make tf-validate   Validate terraform configuration"
	@echo "  make clean         Clean build and cache artifacts"

install-dev:
	pip install -r requirements-dev.txt

lint:
	flake8 app/

format:
	black app/

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

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache .coverage coverage.xml htmlcov staticfiles
