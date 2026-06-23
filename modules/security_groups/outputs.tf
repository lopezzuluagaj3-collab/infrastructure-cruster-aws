output "sg_proxy_id" {
  value = aws_security_group.SG_proxy.id
}

output "sg_airflow_id" {
  value = aws_security_group.SG_airflow.id
}

output "sg_worker_airflow_id" {
  value = aws_security_group.SG_worker_airflow.id
}

output "sg_rabbitmq_id" {
  value = aws_security_group.SG_Rabbitmq.id
}


