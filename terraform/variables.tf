variable "aws_region"           { default = "ap-south-1" }
variable "ecr_repository_name"  { default = "django-ecs-gitops" }
variable "ecs_cluster_name"     { default = "django-app-cluster" }
variable "ecs_service_name"     { default = "django-app-service" }
variable "image_tag"            { default = "latest" }
variable "allowed_hosts"        { default = "localhost" }
variable "vpc_id"               {}
variable "subnet_ids"           { type = list(string) }
variable "db_host"              {}
variable "db_name"              { default = "appdb" }
variable "secret_key_arn"       {}
variable "db_user_arn"          {}
variable "db_password_arn"      {}
