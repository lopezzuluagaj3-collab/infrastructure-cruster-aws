# ====================================================
# MÓDULO: compute
# Responsable de: todas las instancias EC2
# ====================================================

resource "aws_instance" "svr_proxy" {
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

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-svr-proxy"
    }
  )
}

resource "aws_instance" "svr_rabbitmq" {
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

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-svr-rabbitmq"
    }
  )
}

resource "aws_instance" "svr_airflow" {
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

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-svr-airflow-master"
    }
  )
}

resource "aws_instance" "svr_airflow_workers" {
  for_each = {
    "worker-1" = "svr-airflow-worker-1"
    "worker-2" = "svr-airflow-worker-2"
    "worker-3" = "svr-airflow-worker-3"
  }
  ami                    = var.ami
  instance_type          = "t3.small"
  subnet_id              = var.subnet_privada_id
  vpc_security_group_ids = [var.sg_worker_airflow_id]
  key_name               = var.key_general
  iam_instance_profile   = var.instance_profile_name

  root_block_device {
    volume_size           = 32
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-${each.value}"
    }
  )
}

