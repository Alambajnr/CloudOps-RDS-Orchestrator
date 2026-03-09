
output "lambda_function_name" {
  value = aws_lambda_function.rds_manager.function_name
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.rds_manager.name
}

output "cloudwatch_logs_console_url" {
  description = "Click this link to see if the Lambda ran successfully"
  value       = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#logsV2:log-groups/log-group/${urlencode(aws_cloudwatch_log_group.rds_manager.name)}"
}

output "patrolled_regions" {
  value = var.target_regions
}