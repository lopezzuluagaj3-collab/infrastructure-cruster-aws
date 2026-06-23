# ====================================================
# MÓDULO: compute
# Responsable de: todas las instancias EC2
# ====================================================

resource "aws_instance" "SVR_proxy" {
  ami                    = var.ami
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_publica_id
  vpc_security_group_ids = [var.sg_proxy_id]
  key_name               = var.key_proxy

  root_block_device {
    volume_size           = 32
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = { Name = "svr-proxy-node" }
}

resource "aws_instance" "SVR_rabbitmq" {
  ami                    = var.ami
  instance_type          = "t3.small"
  subnet_id              = var.subnet_privada_id
  vpc_security_group_ids = [var.sg_rabbitmq_id]
  key_name               = var.key_general

  root_block_device {
    volume_size           = 32
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = { Name = "svr-rabbitmq-node" }
}

resource "aws_instance" "SVR_airflow" {
  ami                    = var.ami
  instance_type          = "t3.small"
  subnet_id              = var.subnet_privada_id
  vpc_security_group_ids = [var.sg_airflow_id]
  key_name               = var.key_general

  root_block_device {
    volume_size           = 64
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = { Name = "svr-airflow-master" }
}

resource "aws_instance" "SVR_airflow_workers" {
  count                  = 3
  ami                    = var.ami
  instance_type          = "t3.small"
  subnet_id              = var.subnet_privada_id
  vpc_security_group_ids = [var.sg_worker_airflow_id]
  key_name               = var.key_general
  iam_instance_profile = var.instance_profile_name

  root_block_device {
    volume_size           = 32
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = { Name = "svr-airflow-worker" }
}

