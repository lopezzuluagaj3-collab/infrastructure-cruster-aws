output "proxy_public_ip" {
  description = "IP pública del proxy (punto de entrada SSH)"
  value       = aws_instance.SVR_proxy.public_ip
}

output "airflow_private_ip" {
  description = "IP privada del Airflow master"
  value       = aws_instance.SVR_airflow.private_ip
}

output "SVR_airflow_workers_ip" {
  description = "IP privada de los workers"
  value       = aws_instance.SVR_airflow_workers[*].private_ip
}

output "rabbitmq_private_ip" {
  description = "IP privada de RabbitMQ"
  value       = aws_instance.SVR_rabbitmq.private_ip
}
