output "sg_proxy_id" {
  description = "ID del security group del proxy"
  value       = aws_security_group.sg_proxy.id
}

output "sg_ia_id" {
  description = "ID del security group de Airflow (IA)"
  value       = aws_security_group.sg_ia.id
}

output "sg_front_id" {
  description = "ID del security group de workers (front)"
  value       = aws_security_group.sg_front.id
}

output "sg_back_id" {
  description = "ID del security group de RabbitMQ (back)"
  value       = aws_security_group.sg_back.id
}

output "sg_db_id" {
  description = "ID del security group de DB"
  value       = aws_security_group.sg_db.id
}



