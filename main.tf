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
  proxy_eip_allocation_id = "eipalloc-0e19fa47bcb2ae1e6"
  ami                  = "ami-0b6d9d3d33ba97d99"
  subnet_publica_id    = module.networking.subnet_publica_id
  subnet_privada_id    = module.networking.subnet_privada_id
  sg_proxy_id          = module.security_groups.sg_proxy_id
  sg_ia_id             = module.security_groups.sg_ia_id
  sg_front_id          = module.security_groups.sg_front_id
  sg_back_id           = module.security_groups.sg_back_id
  sg_db_id             = module.security_groups.sg_db_id
  key_proxy            = var.KEY_PROXY
  key_general          = var.KEY_GENERAL
  environment          = var.environment
  owner                = var.owner
}

# Módulo iam_s3 comentado temporalmente (sin uso por el momento)
# module "iam_s3" {
#   source = "./modules/iam_s3"
#   bucket_name   = "bucket-for-testing-2026"
#   iam_user_name = "airflow-logs-user"
#   role_name     = "airflow-worker-role"
#   environment   = var.environment
#   owner         = var.owner
# }
