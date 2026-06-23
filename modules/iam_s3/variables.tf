variable "bucket_name" {
  description = "Nombre del bucket S3"
  type        = string
}

variable "iam_user_name" {
  description = "Nombre del usuario IAM"
  type        = string
}

variable "role_name" {
  description = "Nombre del rol IAM para las EC2"
  type        = string
}