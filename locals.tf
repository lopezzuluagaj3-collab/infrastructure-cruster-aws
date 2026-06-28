locals {
  common_tags = {
    Project     = "terraform-aws-cluster-practice"
    ManagedBy   = "Terraform"
    Owner       = var.owner
    Environment = var.environment
  }
}
