variable "cidr_vpc" {
  description = "CIDR block de la VPC (debe ser rango privado RFC1918)"
  type        = string

  validation {
    condition     = can(regex("^10\\.", var.cidr_vpc)) || can(regex("^172\\.1[6-9]\\.", var.cidr_vpc)) || can(regex("^172\\.2[0-9]\\.", var.cidr_vpc)) || can(regex("^192\\.168\\.", var.cidr_vpc))
    error_message = "CIDR debe ser rango privado RFC1918 (10.0.0.0/8, 172.16.0.0/12 o 192.168.0.0/16)."
  }
}

variable "cidr_publica" {
  description = "CIDR block de la subnet pública"
  type        = string
}

variable "cidr_privada" {
  description = "CIDR block de la subnet privada"
  type        = string
}

variable "az" {
  description = "Availability Zone"
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
