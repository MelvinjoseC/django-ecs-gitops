#!/bin/bash
# -----------------------------------------------------------------------------
# Script to bootstrap secure SSM parameters for AWS ECS task definition.
# Usage: ./scripts/setup_secrets.sh
# -----------------------------------------------------------------------------

set -euo pipefail

# Allow overriding variables via environment variables
REGION="${AWS_DEFAULT_REGION:-ap-south-1}"
PREFIX="${SSM_PARAMETER_PREFIX:-/django-ecs-gitops}"

echo "=== Bootstrapping SSM Parameters for $PREFIX in region $REGION ==="

# Dependency Check
for cmd in aws python3; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: Required dependency '$cmd' is not installed." >&2
    exit 1
  fi
done

echo "Checking AWS connectivity..."
if ! aws sts get-caller-identity &>/dev/null; then
  echo "Error: Unable to authenticate with AWS. Check your AWS credentials." >&2
  exit 1
fi

echo "Creating secret key..."
SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_urlsafe(50))')
aws ssm put-parameter \
  --name "$PREFIX/secret_key" \
  --value "$SECRET_KEY" \
  --type "SecureString" \
  --region "$REGION" \
  --overwrite >/dev/null

echo "Creating database username parameter..."
aws ssm put-parameter \
  --name "$PREFIX/db_user" \
  --value "appuser" \
  --type "SecureString" \
  --region "$REGION" \
  --overwrite >/dev/null

# Prompt for database password securely with validation
while true; do
  read -sp "Enter Database Password (cannot be blank): " DB_PASS
  echo ""
  if [[ -n "$DB_PASS" ]]; then
    break
  fi
  echo "Error: Password cannot be blank." >&2
done

echo "Creating database password parameter..."
aws ssm put-parameter \
  --name "$PREFIX/db_password" \
  --value "$DB_PASS" \
  --type "SecureString" \
  --region "$REGION" \
  --overwrite >/dev/null

echo "SSM parameter setup completed successfully!"
echo "-----------------------------------------------------------------------------"
echo "Add these parameter names or ARNs to your terraform/terraform.tfvars file:"
echo "-----------------------------------------------------------------------------"
aws ssm describe-parameters \
  --region "$REGION" \
  --query "Parameters[?starts_with(Name, '$PREFIX')].{Name:Name,Type:Type}" \
  --output table

