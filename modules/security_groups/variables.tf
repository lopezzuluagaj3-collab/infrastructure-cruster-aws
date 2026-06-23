variable "vpc_id" {
  description = "ID de la VPC donde se crean los security groups"
  type        = string
}

variable "cidr_vpc" {
  description = "CIDR de la VPC - usado para puertos efímeros de Spark workers"
  type        = string
}
