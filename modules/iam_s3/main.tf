# 1. Bucket
resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
}

# 2. User para logs de Airflow
resource "aws_iam_user" "airflow_logs_user" {
  name = var.iam_user_name
}

resource "aws_iam_user_policy" "logs_policy" {
  name = "airflow-logs-write"
  user = aws_iam_user.airflow_logs_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:GetObject"]
      Resource = "${aws_s3_bucket.main.arn}/logs/*"
    }]
  })
}

# 3. Rol para los workers EC2
resource "aws_iam_role" "worker_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "worker_s3_policy" {
  name = "worker-s3-access"
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
  name = "${var.role_name}-profile"
  role = aws_iam_role.worker_role.name
}