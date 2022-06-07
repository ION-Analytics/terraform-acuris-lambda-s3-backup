output "lambda_arn" {
  value = aws_lambda_function.lambda_function.arn
}

output "task_role_arn" {
  value = module.s3_backup_taskdef.task_role_arn
}

