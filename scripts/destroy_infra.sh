#!/bin/bash
# -----------------------------------------------------------------------------
# Script to safely decommission/teardown AWS resources created for the project.
# Usage: ./scripts/destroy_infra.sh
# -----------------------------------------------------------------------------

set -euo pipefail

REGION="${AWS_DEFAULT_REGION:-ap-south-1}"
PREFIX="${SSM_PARAMETER_PREFIX:-/django-ecs-gitops}"

echo "WARNING: This will destroy the AWS infrastructure and clean up SSM parameters!"
read -p "Are you absolutely sure you want to proceed? (yes/NO): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Aborted."
  exit 0
fi

echo "Destroying infrastructure via Terraform..."
if [ -d "terraform" ]; then
  cd terraform
  terraform init
  terraform destroy -auto-approve
  cd ..
fi

echo "Cleaning up SSM parameters..."
aws ssm delete-parameters \
  --names "$PREFIX/secret_key" "$PREFIX/db_user" "$PREFIX/db_password" \
  --region "$REGION" || echo "SSM Parameters already deleted or not found."

echo "Cleanup complete."
