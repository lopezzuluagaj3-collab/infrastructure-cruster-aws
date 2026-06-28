output "proxy_public_ip" {
  description = "IP pública del servidor proxy (punto de entrada SSH)"
  value       = module.compute.proxy_public_ip
}

output "airflow_private_ip" {
  description = "IP privada del servidor Airflow master"
  value       = module.compute.airflow_private_ip
}

output "rabbitmq_private_ip" {
  description = "IP privada de RabbitMQ"
  value       = module.compute.rabbitmq_private_ip
}

output "db_private_ip" {
  description = "IP privada de la base de datos"
  value       = module.compute.db_private_ip
}

output "all_workers_private_ips" {
  description = "Mapa de nombre de worker a IP privada"
  value       = module.compute.workers_private_ips
}

output "all_instances_ids" {
  description = "Mapa de nombre a ID de instancia"
  value       = module.compute.all_instances_ids
}

output "all_instances_public_ips" {
  description = "Mapa de nombre a IP pública (solo proxy tendrá IP pública)"
  value       = module.compute.all_instances_public_ips
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




