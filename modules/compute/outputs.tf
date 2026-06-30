output "proxy_public_ip" {
  description = "IP pública del proxy (punto de entrada SSH)"
  value       = aws_instance.svr_proxy.public_ip
}

output "ia_private_ip" {
  description = "IP privada del servidor IA (Airflow)"
  value       = aws_instance.svr_ia.private_ip
}

output "back_private_ip" {
  description = "IP privada del servidor Back (RabbitMQ)"
  value       = aws_instance.svr_back.private_ip
}

output "db_private_ip" {
  description = "IP privada de la base de datos"
  value       = aws_instance.svr_db.private_ip
}

output "front_private_ip" {
  description = "IP privada del servidor Front"
  value       = aws_instance.svr_front.private_ip
}

output "all_instances_ids" {
  description = "Mapa de nombre a ID de instancia"
  value = {
    proxy = aws_instance.svr_proxy.id
    back  = aws_instance.svr_back.id
    ia    = aws_instance.svr_ia.id
    db    = aws_instance.svr_db.id
    front = aws_instance.svr_front.id
  }
}

output "all_instances_public_ips" {
  description = "Mapa de nombre a IP pública (solo proxy tendrá IP pública)"
  value = {
    proxy = aws_instance.svr_proxy.public_ip
    back  = aws_instance.svr_back.public_ip
    ia    = aws_instance.svr_ia.public_ip
    db    = aws_instance.svr_db.public_ip
    front = aws_instance.svr_front.public_ip
  }
}
