# django-ecs-gitops

A production-ready Django REST API deployed to AWS ECS Fargate with a full GitHub Actions CI/CD pipeline.

## What this project demonstrates

- GitHub Actions pipeline: test → security scan → Docker build → ECR push → Terraform → ECS deploy
- Trivy vulnerability scanning on every build (DevSecOps)
- Terraform-managed AWS infrastructure (ECS, ALB, ECR, CloudWatch, IAM)
- Django REST API with PostgreSQL on RDS
- Automated DB migrations via ECS run-task
- CloudWatch alarms + Slack notifications

## Tech stack

| Layer       | Technology                        |
|-------------|-----------------------------------|
| App         | Django 4.2, Django REST Framework |
| Container   | Docker, AWS ECR                   |
| Infra       | Terraform, AWS ECS Fargate, ALB   |
| CI/CD       | GitHub Actions                    |
| Security    | Trivy, AWS IAM, SSM SecureString  |
| Monitoring  | AWS CloudWatch, SNS, Slack        |
| Database    | PostgreSQL (RDS)                  |

## Local development

```bash
# Clone and start locally
git clone https://github.com/YOUR_USERNAME/django-ecs-gitops
cd django-ecs-gitops
cp .env.example .env
docker compose up --build
```

API will be at: http://localhost:8000/api/tasks/

## Uploading to your GitHub Repository

To push this codebase to your own GitHub repository:

1. Create a new repository on GitHub (do **not** initialize it with a README, license, or `.gitignore` since they are already provided here).
2. Open your terminal in this project directory and run:
   ```bash
   # Initialize git if not already initialized
   git init

   # Add all files to the repository
   git add .

   # Commit files
   git commit -m "Initial commit - AWS ready"

   # Rename default branch to main
   git branch -M main

   # Add your GitHub repository as the remote origin
   git remote add origin https://github.com/<your-github-username>/<your-repo-name>.git

   # Push to main branch
   git push -u origin main
   ```

## GitHub Actions secrets required

Add these in your repository **Settings → Secrets and variables → Actions → New repository secret**:

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | Your AWS IAM User access key (needs permissions to manage ECS, ECR, ALB, IAM, CloudWatch) |
| `AWS_SECRET_ACCESS_KEY` | Your AWS IAM User secret access key |
| `SUBNET_ID` | One of the public subnet IDs from your VPC (the ones used in `terraform.tfvars`) |
| `SECURITY_GROUP_ID` | The ECS task security group ID (available as `ecs_tasks_security_group_id` output after running Terraform) |
| `SLACK_WEBHOOK_URL` | (Optional) Slack incoming webhook URL for pipeline notifications |

## Deploy infrastructure

```bash
# 1. Store secrets in SSM
bash scripts/setup_secrets.sh


# 2. Configure Terraform
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform.tfvars with your VPC, subnet, RDS details

# 3. Apply infrastructure
cd terraform
terraform init
terraform plan
terraform apply
```

## Pipeline stages

```
push to main
    ├── test & lint (pytest + flake8 + coverage)
    ├── trivy security scan
    ├── build & push Docker image to ECR
    ├── terraform apply (infra update)
    ├── ECS deploy + django migrate
    └── Slack notification (success/failure)
```

## API endpoints

| Method | Endpoint           | Description       |
|--------|--------------------|-------------------|
| GET    | /api/tasks/        | List all tasks    |
| POST   | /api/tasks/        | Create a task     |
| GET    | /api/tasks/{id}/   | Get task detail   |
| PATCH  | /api/tasks/{id}/   | Update task       |
| DELETE | /api/tasks/{id}/   | Delete task       |

Search: `/api/tasks/?search=todo`
Filter by status: `/api/tasks/?search=in_progress`
