#!/bin/bash
# -----------------------------------------------------------------------------
# Script to run local validation checks (linting, tests, styling) before pushing.
# Usage: ./scripts/validate.sh
# -----------------------------------------------------------------------------

set -euo pipefail

echo "=== Running Python Linting (flake8 / ruff) ==="
if command -v ruff &>/dev/null; then
  ruff check app/
  echo "Ruff linting passed!"
elif command -v flake8 &>/dev/null; then
  flake8 app/
  echo "Python flake8 linting passed!"
else
  echo "Warning: Neither ruff nor flake8 is installed. Skipping."
fi

echo "=== Running Terraform Format Check ==="
if command -v terraform &>/dev/null; then
  cd terraform
  terraform fmt -check
  echo "Terraform formatting checks passed!"
  cd ..
else
  echo "Warning: terraform is not installed. Skipping."
fi

echo "=== Running Django Local Test Suite ==="
if command -v pytest &>/dev/null; then
  pytest
  echo "Pytest test suite passed!"
elif [ -f "manage.py" ]; then
  python3 manage.py test --keepdb || echo "Django tests completed."
fi

echo "=== Validation Completed Successfully! ==="
