locals {
  common_tags = {
    Project     = "terraform-aws-cluster-practice"
    ManagedBy   = "Terraform"
    Owner       = var.owner
    Environment = var.environment
  }

  name_prefix = "${var.environment}-${var.owner}"
}
