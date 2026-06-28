output "sg_proxy_id" {
  description = "ID del security group del proxy"
  value       = aws_security_group.sg_proxy.id
}

output "sg_airflow_id" {
  description = "ID del security group de Airflow master"
  value       = aws_security_group.sg_airflow.id
}

output "sg_worker_airflow_id" {
  description = "ID del security group de workers de Airflow"
  value       = aws_security_group.sg_worker_airflow.id
}

output "sg_rabbitmq_id" {
  description = "ID del security group de RabbitMQ"
  value       = aws_security_group.sg_rabbitmq.id
}


