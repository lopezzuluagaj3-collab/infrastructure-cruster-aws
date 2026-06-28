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

output "db_private_ip" {
  description = "IP privada de la base de datos"
  value       = aws_instance.svr_db.private_ip
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
    db       = aws_instance.svr_db.id
    workers  = { for k, v in aws_instance.svr_airflow_workers : k => v.id }
  }
}

output "all_instances_public_ips" {
  description = "Mapa de nombre a IP pública (solo proxy tendrá IP pública)"
  value = {
    proxy    = aws_instance.svr_proxy.public_ip
    rabbitmq = aws_instance.svr_rabbitmq.public_ip
    airflow  = aws_instance.svr_airflow.public_ip
    db       = aws_instance.svr_db.public_ip
    workers  = { for k, v in aws_instance.svr_airflow_workers : k => v.public_ip }
  }
}
