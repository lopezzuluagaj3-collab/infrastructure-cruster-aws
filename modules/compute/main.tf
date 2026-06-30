resource "aws_instance" "svr_proxy" {
  ami                    = var.ami
  instance_type          = "t3.small"
  subnet_id              = var.subnet_publica_id
  vpc_security_group_ids = [var.sg_proxy_id]
  key_name               = var.key_proxy

  root_block_device {
    volume_size           = 32
    volume_type           = "gp3"
    encrypted             = false
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

resource "aws_instance" "svr_back" {
  ami                    = var.ami
  instance_type          = "c7i-flex.large"
  subnet_id              = var.subnet_privada_id
  vpc_security_group_ids = [var.sg_back_id]
  key_name               = var.key_general

  root_block_device {
    volume_size           = 32
    volume_type           = "gp3"
    encrypted             = false
    delete_on_termination = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-svr-back"
    }
  )
}

resource "aws_instance" "svr_ia" {
  ami                    = var.ami
  instance_type          = "m7i-flex.large"
  subnet_id              = var.subnet_privada_id
  vpc_security_group_ids = [var.sg_ia_id]
  key_name               = var.key_general

  root_block_device {
    volume_size           = 64
    volume_type           = "gp3"
    encrypted             = false
    delete_on_termination = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-svr-ia"
    }
  )
}

resource "aws_instance" "svr_front" {
  ami                    = var.ami
  instance_type          = "c7i-flex.large"
  subnet_id              = var.subnet_privada_id
  vpc_security_group_ids = [var.sg_front_id]
  key_name               = var.key_general

  root_block_device {
    volume_size           = 32
    volume_type           = "gp3"
    encrypted             = false
    delete_on_termination = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-svr-front"
    }
  )
}

resource "aws_instance" "svr_db" {
  ami                    = var.ami
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_privada_id
  vpc_security_group_ids = [var.sg_db_id]
  key_name               = var.key_general

  root_block_device {
    volume_size           = 64
    volume_type           = "gp3"
    encrypted             = false
    delete_on_termination = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-svr-db"
    }
  )
}
