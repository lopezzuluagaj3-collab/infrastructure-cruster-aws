output "proxy_public_ip" {
  description = "IP pública del servidor proxy"
  value       = module.compute.proxy_public_ip
}

output "airflow_private_ip" {
  description = "IP privada del servidor Airflow master"
  value       = module.compute.airflow_private_ip
}



