# 1. Bucket

resource "aws_s3_bucket" "main" {
  bucket        = "${local.name_prefix}-${var.bucket_name}"
  force_destroy = false

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-bucket"
    }
  )
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. User para logs de Airflow
resource "aws_iam_user" "airflow_logs_user" {
  name = "${local.name_prefix}-${var.iam_user_name}"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-airflow-logs-user"
    }
  )
}

resource "aws_iam_user_policy" "logs_policy" {
  name = "${local.name_prefix}-airflow-logs-write"
  user = aws_iam_user.airflow_logs_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:GetObject"]
      Resource = "${aws_s3_bucket.main.arn}/logs/*"
      Condition = {
        StringEquals = {
          "s3:x-amz-acl" = "bucket-owner-full-control"
        }
      }
    }]
  })
}

# 3. Rol para los workers EC2
resource "aws_iam_role" "worker_role" {
  name = "${local.name_prefix}-${var.role_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-worker-role"
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role_policy" "worker_s3_policy" {
  name = "${local.name_prefix}-worker-s3-access"
  role = aws_iam_role.worker_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = "${aws_s3_bucket.main.arn}/data/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.main.arn
      }
    ]
  })
}

# 4. Instance profile — envuelve el rol para asignarlo a EC2
resource "aws_iam_instance_profile" "worker_profile" {
  name = "${local.name_prefix}-${var.role_name}-profile"
  role = aws_iam_role.worker_role.name

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-worker-profile"
    }
  )
}