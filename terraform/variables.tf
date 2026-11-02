variable "aws_region" {
  type        = string
  default     = "ap-south-1"
  description = "The AWS region where resources will be deployed"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "The aws_region variable must be a valid AWS region identifier (e.g., us-east-1, ap-south-1)."
  }
}

variable "ecr_repository_name" {
  type        = string
  default     = "django-ecs-gitops"
  description = "The name of the AWS ECR repository"
}

variable "ecs_cluster_name" {
  type        = string
  default     = "django-app-cluster"
  description = "The name of the ECS cluster"
}

variable "ecs_service_name" {
  type        = string
  default     = "django-app-service"
  description = "The name of the ECS service"
}

variable "image_tag" {
  type        = string
  default     = "latest"
  description = "The tag of the Docker image to deploy"
}

variable "allowed_hosts" {
  type        = string
  default     = "localhost"
  description = "Allowed hosts for the Django application (comma separated)"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where resources will be created"

  validation {
    condition     = can(regex("^vpc-[0-9a-f]{8,17}$", var.vpc_id))
    error_message = "The vpc_id must be a valid AWS VPC ID starting with 'vpc-' followed by 8 or 17 hexadecimal characters."
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "The public subnets where ECS task and ALB will be placed"

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least two public subnet IDs must be provided for high availability of the Application Load Balancer."
  }
}

variable "db_host" {
  type        = string
  description = "The database hostname/endpoint"
}

variable "db_name" {
  type        = string
  default     = "appdb"
  description = "The database name"
}

variable "secret_key_arn" {
  type        = string
  description = "The SSM Parameter ARN for the Django Secret Key"
}

variable "db_user_arn" {
  type        = string
  description = "The SSM Parameter ARN for the database username"
}

variable "db_password_arn" {
  type        = string
  description = "The SSM Parameter ARN for the database password"
}

variable "certificate_arn" {
  type        = string
  default     = ""
  description = "Optional ACM SSL certificate ARN for HTTPS ALB listener termination"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to all resources"
  default = {
    Project     = "django-ecs-gitops"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
