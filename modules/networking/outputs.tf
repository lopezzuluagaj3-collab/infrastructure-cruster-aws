output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.vpc_principal.id
}

output "subnet_publica_id" {
  description = "ID de la subnet pública"
  value       = aws_subnet.subnet_publica.id
}

output "subnet_privada_id" {
  description = "ID de la subnet privada"
  value       = aws_subnet.subnet_privada.id
}
