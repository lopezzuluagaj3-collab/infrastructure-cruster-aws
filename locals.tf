locals {
  common_tags = {
    Project     = "terraform-aws-cluster-practice"
    ManagedBy   = "Terraform"
    Environment = var.environment
  }

  name_prefix = var.environment
}
