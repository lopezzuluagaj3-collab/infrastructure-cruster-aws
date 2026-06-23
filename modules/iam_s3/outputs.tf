output "bucket_name" {
  description = "Nombre del bucket S3"
  value       = aws_s3_bucket.main.bucket
}

output "bucket_arn" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.main.arn
}

output "instance_profile_name" {
  description = "ARN del instance profile para asignar a los workers EC2"
  value       = aws_iam_instance_profile.worker_profile.name
}

output "airflow_logs_user_name" {
  description = "Nombre del usuario IAM para logs de Airflow"
  value       = aws_iam_user.airflow_logs_user.name
}