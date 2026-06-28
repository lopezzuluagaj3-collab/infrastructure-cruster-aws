variable "ami" {
  description = "AMI para todas las instancias EC2"
  type        = string
}

variable "subnet_publica_id" {
  description = "ID de la subnet pública (para el proxy)"
  type        = string
}

variable "subnet_privada_id" {
  description = "ID de la subnet privada (para todos los demás)"
  type        = string
}

variable "sg_proxy_id" {
  description = "ID del security group del proxy"
  type        = string
}

variable "sg_airflow_id" {
  description = "ID del security group de Airflow"
  type        = string
}

variable "sg_worker_airflow_id" {
  description = "ID del security group de workers de Airflow"
  type        = string
}

variable "sg_rabbitmq_id" {
  description = "ID del security group de RabbitMQ"
  type        = string
}

variable "key_proxy" {
  description = "Key pair para el servidor proxy"
  type        = string
  sensitive   = true
}

variable "key_general" {
  description = "Key pair para los servidores privados"
  type        = string
  sensitive   = true
}

variable "instance_profile_name" {
  description = "Nombre del instance profile para los workers"
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
