output "proxy_public_ip" {
  description = "IP pública del proxy (punto de entrada SSH)"
  value       = aws_instance.svr_proxy.public_ip
}

output "airflow_private_ip" {
  description = "IP privada del Airflow master"
  value       = aws_instance.svr_airflow.private_ip
}

output "rabbitmq_private_ip" {
  description = "IP privada de RabbitMQ"
  value       = aws_instance.svr_rabbitmq.private_ip
}

output "workers_private_ips" {
  description = "Mapa de nombre de worker a IP privada"
  value       = { for k, v in aws_instance.svr_airflow_workers : k => v.private_ip }
}

output "all_instances_ids" {
  description = "Mapa de nombre a ID de instancia"
  value = {
    proxy    = aws_instance.svr_proxy.id
    rabbitmq = aws_instance.svr_rabbitmq.id
    airflow  = aws_instance.svr_airflow.id
    workers  = { for k, v in aws_instance.svr_airflow_workers : k => v.id }
  }
}
