provider "aws" {
  region = "us-east-1"
}

module "iam_s3" {
  source = "./modules/iam_s3"

  bucket_name   = "bucket-for-testing-2026"
  iam_user_name = "airflow-logs-user"
  role_name     = "airflow-worker-role"
}

module "networking" {
  source = "./modules/networking"

  cidr_vpc      = "24.0.0.0/16"
  cidr_publica  = "24.0.1.0/24"
  cidr_privada  = "24.0.2.0/24"
  az            = "us-east-1a"
}

module "security_groups" {
  source = "./modules/security_groups"

  vpc_id   = module.networking.vpc_id
  cidr_vpc = "24.0.0.0/16"
}

module "compute" {
  source = "./modules/compute"

  ami                  = "ami-091138d0f0d41ff90"
  subnet_publica_id    = module.networking.subnet_publica_id
  subnet_privada_id    = module.networking.subnet_privada_id
  sg_proxy_id          = module.security_groups.sg_proxy_id
  sg_airflow_id        = module.security_groups.sg_airflow_id
  sg_worker_airflow_id = module.security_groups.sg_worker_airflow_id
  sg_rabbitmq_id       = module.security_groups.sg_rabbitmq_id
  key_proxy            = var.KEY_PROXY
  key_general          = var.KEY_GENERAL
  instance_profile_name = module.iam_s3.instance_profile_name
}
