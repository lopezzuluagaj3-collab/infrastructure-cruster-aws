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

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Responsable del proyecto"
  type        = string
  default     = "estudiante"
}