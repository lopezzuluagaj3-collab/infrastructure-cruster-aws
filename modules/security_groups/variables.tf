variable "vpc_id" {
  description = "ID de la VPC donde se crean los security groups"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR de la VPC para reglas internas"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR desde el cual se permite SSH al proxy"
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
