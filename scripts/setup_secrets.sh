#!/bin/bash
# Run once to store secrets in AWS SSM Parameter Store
# Usage: bash scripts/setup_secrets.sh

set -e

REGION="ap-south-1"
PREFIX="/django-ecs-gitops"

echo "Creating SSM parameters..."

aws ssm put-parameter \
  --name "$PREFIX/secret_key" \
  --value "$(python3 -c 'import secrets; print(secrets.token_urlsafe(50))')" \
  --type "SecureString" \
  --region "$REGION" \
  --overwrite

aws ssm put-parameter \
  --name "$PREFIX/db_user" \
  --value "appuser" \
  --type "SecureString" \
  --region "$REGION" \
  --overwrite

read -sp "Enter DB password: " DB_PASS
echo ""
aws ssm put-parameter \
  --name "$PREFIX/db_password" \
  --value "$DB_PASS" \
  --type "SecureString" \
  --region "$REGION" \
  --overwrite

echo "Done. Add these ARNs to your terraform.tfvars:"
aws ssm describe-parameters \
  --filters "Key=Name,Values=$PREFIX" \
  --query "Parameters[*].{Name:Name,ARN:ARN}" \
  --region "$REGION" \
  --output table
