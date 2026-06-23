# ====================================================
# MÓDULO: security_groups
# Responsable de: todos los Security Groups del proyecto
# ====================================================

resource "aws_security_group" "SG_proxy" {
  name        = "SG_proxy"
  description = "Grupo de seguridad para el proxy - expuesto al mundo"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "UI proxy"
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "SG_airflow" {
  name        = "SG_airflow"
  description = "Grupo de seguridad para Airflow master - solo desde proxy"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP Airflow UI"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.SG_proxy.id]
  }
  ingress {
    description     = "SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.SG_proxy.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "SG_worker_airflow" {
  name        = "SG_worker_airflow"
  description = "Grupo de seguridad para los workers de Airflow"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.SG_proxy.id]
  }
  ingress {
    description     = "Flower UI"
    from_port       = 5555
    to_port         = 5555
    protocol        = "tcp"
    security_groups = [aws_security_group.SG_proxy.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "SG_Rabbitmq" {
  name        = "SG_Rabbitmq"
  description = "Grupo de seguridad para RabbitMQ"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.SG_proxy.id]
  }
  ingress {
    description     = "AMQP - solo desde Airflow"
    from_port       = 5672
    to_port         = 5672
    protocol        = "tcp"
    security_groups = [aws_security_group.SG_airflow.id]
  }
  ingress {
    description     = "UI RabbitMQ"
    from_port       = 15672
    to_port         = 15672
    protocol        = "tcp"
    security_groups = [aws_security_group.SG_proxy.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



