variable "aws_region" {
  description = "Región de AWS para desplegar la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "owner" {
  description = "Nombre del responsable del proyecto"
  type        = string
  default     = "estudiante"
}

variable "environment" {
  description = "prod"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "El ambiente debe ser dev, staging o prod."
  }
}

variable "allowed_ssh_cidr" {
  description = "CIDR desde el cual se permite conexión SSH al proxy"
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "Debe ser un CIDR válido (ej: 203.0.113.0/24)."
  }
}

variable "KEY_PROXY" {
  description = "Nombre del key pair para el servidor proxy"
  type        = string
  sensitive   = true
}

variable "KEY_GENERAL" {
  description = "Nombre del key pair para los servidores privados"
  type        = string
  sensitive   = true
}

variable "proxy_eip_allocation_id" {
  description = "Allocation ID de la Elastic IP existente para el proxy. Si se deja vacío, Terraform crea una nueva EIP."
  type        = string
  default     = ""
}
