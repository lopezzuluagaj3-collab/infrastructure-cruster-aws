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
  type = string
}

variable "sg_airflow_id" {
  type = string
}

variable "sg_worker_airflow_id" {
  type = string
}

variable "sg_rabbitmq_id" {
  type = string
}


variable "key_proxy" {
  description = "Key pair para el servidor proxy"
  type        = string
}

variable "key_general" {
  description = "Key pair para los servidores privados"
  type        = string
}


variable "instance_profile_name" {
  description = "ARN del instance profile para los workers"
  type        = string
}
