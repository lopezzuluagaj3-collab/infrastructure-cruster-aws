provider "aws" {
  region = var.aws_region
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "iam_s3" {
  source = "./modules/iam_s3"

  bucket_name   = "bucket-for-testing-2026"
  iam_user_name = "airflow-logs-user"
  role_name     = "airflow-worker-role"
  environment   = var.environment
  owner         = var.owner
}

module "networking" {
  source = "./modules/networking"

  cidr_vpc     = "10.0.0.0/16"
  cidr_publica = "10.0.1.0/24"
  cidr_privada = "10.0.2.0/24"
  az           = data.aws_availability_zones.available.names[0]
  environment  = var.environment
  owner        = var.owner
}

module "security_groups" {
  source = "./modules/security_groups"

  vpc_id           = module.networking.vpc_id
  vpc_cidr         = "10.0.0.0/16"
  allowed_ssh_cidr = var.allowed_ssh_cidr
  environment      = var.environment
  owner            = var.owner
}

module "compute" {
  source = "./modules/compute"

  ami                   = data.aws_ami.amazon_linux_2.id
  subnet_publica_id     = module.networking.subnet_publica_id
  subnet_privada_id     = module.networking.subnet_privada_id
  sg_proxy_id           = module.security_groups.sg_proxy_id
  sg_airflow_id         = module.security_groups.sg_airflow_id
  sg_worker_airflow_id  = module.security_groups.sg_worker_airflow_id
  sg_rabbitmq_id        = module.security_groups.sg_rabbitmq_id
  key_proxy             = var.KEY_PROXY
  key_general           = var.KEY_GENERAL
  instance_profile_name = module.iam_s3.instance_profile_name
  environment           = var.environment
  owner                 = var.owner
}
