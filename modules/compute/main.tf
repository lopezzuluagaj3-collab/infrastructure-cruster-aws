

resource "aws_instance" "svr_proxy" {
  ami                    = var.ami
  instance_type          = "t3.small"
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

resource "aws_eip" "proxy_eip" {
  count    = var.proxy_eip_allocation_id == "" ? 1 : 0
  domain   = "vpc"
  instance = aws_instance.svr_proxy.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-proxy-eip"
    }
  )
}

resource "aws_eip_association" "proxy_eip_assoc" {
  count         = var.proxy_eip_allocation_id == "" ? 0 : 1
  instance_id   = aws_instance.svr_proxy.id
  allocation_id = var.proxy_eip_allocation_id
}

resource "aws_instance" "svr_rabbitmq" {
  ami                    = var.ami
  instance_type          = "t3.medium"
  subnet_id              = var.subnet_privada_id
  vpc_security_group_ids = [var.sg_back_id]
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
  instance_type          = "t3.large"
  subnet_id              = var.subnet_privada_id
  vpc_security_group_ids = [var.sg_ia_id]
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
  instance_type          = "t3.medium"
  subnet_id              = var.subnet_privada_id
  vpc_security_group_ids = [var.sg_front_id]
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
      Name = "${local.name_prefix}-${each.value}"
    }
  )
}

resource "aws_instance" "svr_db" {
  ami                    = var.ami
  instance_type          = "t3.small"
  subnet_id              = var.subnet_privada_id
  vpc_security_group_ids = [var.sg_db_id]
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
      Name = "${local.name_prefix}-svr-db"
    }
  )
}

