# Production-Grade Django ECS GitOps

A highly optimized, production-ready Django REST API deployed to AWS ECS Fargate with automated resource scaling, deep security hardening, and a robust GitOps CI/CD pipeline using GitHub Actions.

## Upgraded DevOps Architecture

This repository has been refactored and optimized according to modern production-grade cloud standards. The key improvements include:

*   **Secure Containerization:**
    *   **Multi-Stage Build:** Decreases image size and attack surface by isolating build dependencies from the runtime image.
    *   **Non-Root Execution:** Runs the application as a restricted system user (`appuser`), minimizing host compromise risks.
    *   **Native Python Healthcheck:** Replaces heavy external dependencies like `curl` in the Dockerfile with a lightweight python healthcheck script.
*   **Infrastructure as Code (Terraform):**
    *   **Modularization:** Split monolithic `main.tf` into functional modules (`provider.tf`, `ecr.tf`, `ecs.tf`, `monitoring.tf`, `security_groups.tf`, `iam.tf`, `autoscaling.tf`).
    *   **Least Privilege IAM:** Restricted SSM parameter store access only to the explicit ARNs of required secrets.
    *   **Global Tagging:** Integrated default tags into the AWS provider config.
    *   **ECS Task Autoscaling:** Configured auto-scaling policies based on CPU and memory utilization thresholds.
    *   **Predictable Deployments:** Enabled state locking templates (`backend.tf.example`).
*   **Django Application Improvements:**
    *   **Structured Logs:** Integrated `python-json-logger` for JSON-formatted console outputs, facilitating easier parsing in CloudWatch.
    *   **Database Health Check:** Added a native API endpoint (`/api/health/`) verifying database connectivity.
    *   **Security Hardening:** Enforced SSL redirects, secure session/CSRF cookies, and HSTS headers.
*   **Developer Experience & Validation:**
    *   **Pre-Commit Hooks:** Styled with Black, flake8, and terraform fmt using `.pre-commit-config.yaml`.
    *   **Validation Script:** Added `scripts/validate.sh` for fast, pre-push compliance checks.
    *   **Teardown Script:** Added `scripts/destroy_infra.sh` for safe teardown.
*   **GitHub Actions CI/CD Pipeline:**
    *   **Concurrency Limits:** Cancels redundant builds on consecutive pushes.
    *   **Faster Builds:** Leverages caching for python dependencies and Docker build layers.
    *   **Secured Workflows:** Recommends AWS OIDC authentication instead of static keys.
    *   **Deep Scanning:** Inspects container images with Trivy and IaC configurations with tfsec.
    *   **State Integrity:** Applies exact plans (`tfplan`) generated in the plan stage to guarantee predictable apply runs.

---

## Directory Structure

```text
├── .github/workflows/    # CI/CD pipelines (GitHub Actions)
├── app/                  # Django backend application code
│   ├── api/              # REST Framework endpoints, models, views, and tests
│   └── core/             # Project settings, URLs, and WSGI definitions
├── scripts/              # Bootstrap, validation, and teardown scripts
├── terraform/            # Infrastructure-as-code files
├── Dockerfile            # Optimized multi-stage Docker build
├── docker-compose.yml    # Development stack orchestration (includes pgAdmin)
└── requirements.txt      # Production package dependencies
```

---

## Local Development

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/MelvinjoseC/django-ecs-gitops.git
    cd django-ecs-gitops
    ```
2.  **Configure environment:**
    ```bash
    cp .env.example .env
    # Adjust variables as needed
    ```
3.  **Spin up local services:**
    ```bash
    docker compose up --build
    ```
    *   **REST API:** [http://localhost:8000/api/tasks/](http://localhost:8000/api/tasks/)
    *   **Health Status:** [http://localhost:8000/api/health/](http://localhost:8000/api/health/)
    *   **pgAdmin DB Admin Console:** [http://localhost:5050/](http://localhost:5050/) (User: `admin@example.com`, Pass: `admin`)

---

## Infrastructure Deployment

1.  **SSM Parameters Bootstrap:**
    Run the setup script to store secure strings in AWS SSM:
    ```bash
    ./scripts/setup_secrets.sh
    ```
2.  **State Storage Backend Configuration (Recommended):**
    Rename `terraform/backend.tf.example` to `backend.tf` and fill in your remote state S3 bucket and DynamoDB locking table details.
3.  **Provision Resources:**
    ```bash
    cd terraform
    terraform init
    terraform plan -out=tfplan
    terraform apply tfplan
    ```
4.  **Destroy Resources Safely:**
    To decommission the infrastructure and delete SSM secrets:
    ```bash
    ./scripts/destroy_infra.sh
    ```

---

## CI/CD Pipeline Secret Requirements

Configure the following secrets in GitHub **Settings → Secrets and variables → Actions**:

| Secret Name | Description |
| :--- | :--- |
| `AWS_ACCESS_KEY_ID` | Access key for deployment user (if not using OIDC Role) |
| `AWS_SECRET_ACCESS_KEY` | Secret access key for deployment user |
| `SUBNET_ID` | public subnet ID used by Fargate for running migrations task |
| `SECURITY_GROUP_ID` | ECS task security group ID (outputted after terraform apply) |
| `SLACK_WEBHOOK_URL` | (Optional) Incoming Slack webhook for build notifications |
