output "proxy_public_ip" {
  description = "IP pública del servidor proxy (punto de entrada SSH)"
  value       = "34.202.187.239" # IP actual del proxy en AWS
}

output "ia_private_ip" {
  description = "IP privada del servidor IA (Airflow)"
  value       = "10.0.2.243" # IP actual en AWS
}

output "back_private_ip" {
  description = "IP privada del servidor Back (RabbitMQ)"
  value       = "10.0.2.209" # IP actual en AWS
}

output "db_private_ip" {
  description = "IP privada de la base de datos"
  value       = "10.0.2.91" # IP actual en AWS
}

output "front_private_ip" {
  description = "IP privada del servidor Front"
  value       = "10.0.2.212" # IP actual en AWS
}

output "vpc_id" {
  description = "ID de la VPC creada"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "CIDR de la VPC"
  value       = module.networking.vpc_cidr
}

output "sg_proxy_id" {
  description = "ID del security group del proxy"
  value       = module.security_groups.sg_proxy_id
}
