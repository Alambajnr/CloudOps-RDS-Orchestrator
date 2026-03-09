locals {
  function_name = "${var.resource_name}-${var.region}"
  schedule_name = "${var.resource_name}-${var.region}-scheduler"
}

# --- Lambda Function ---
resource "aws_lambda_function" "rds_manager" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = local.function_name
  role             = aws_iam_role.rdsmanager_iam_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.12"
  timeout          = 60 

  environment {
    variables = {
      TARGET_REGIONS = var.target_regions 
      LOG_LEVEL      = "INFO"
    }
  }
}

# --- CloudWatch Logs ---
resource "aws_cloudwatch_log_group" "rds_manager" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = 30
}

# --- IAM Roles ---

# Lambda Execution Role (Unique per region)
resource "aws_iam_role" "rdsmanager_iam_role" {
  name               = "${local.function_name}-exec-role" 
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "rdsmanager_policy" {
  name   = "rds-management-policy"
  role   = aws_iam_role.rdsmanager_iam_role.id
  policy = data.aws_iam_policy_document.rds_manager_inline_policy.json
}

# Scheduler Role (Unique per region)
resource "aws_iam_role" "scheduler_iam_role" {
  name               = "${local.schedule_name}-role"
  assume_role_policy = data.aws_iam_policy_document.shedule_assume_role.json
}

resource "aws_iam_role_policy" "rdsmanager_schedule_invoke" {
  name   = "allow-lambda-invoke"
  role   = aws_iam_role.scheduler_iam_role.id
  policy = data.aws_iam_policy_document.rds_manager_scheduler.json
}

# --- EventBridge Scheduler ---

resource "aws_scheduler_schedule" "rds_stop" {
  name       = "${local.schedule_name}-stop"
  group_name = "default"

  flexible_time_window { mode = "OFF" }
  schedule_expression          = "cron(13 15 * * ? *)" # 9 PM
  schedule_expression_timezone =  var.timezone       # Example: Set to your local timezone!

  target {
    arn      = aws_lambda_function.rds_manager.arn
    role_arn = aws_iam_role.scheduler_iam_role.arn

    input    = jsonencode({ "switch" : "0" }) 
  }
}

resource "aws_scheduler_schedule" "rds_start" {
  name       = "${local.schedule_name}-start"
  group_name = "default"

  flexible_time_window { mode = "OFF" }
  schedule_expression          = "cron(0 8 * * ? *)" # 8 AM
  schedule_expression_timezone = var.timezone     # Matches the stop timezone

  target {
    arn      = aws_lambda_function.rds_manager.arn
    role_arn = aws_iam_role.scheduler_iam_role.arn
    input    = jsonencode({ "switch" : "1" }) 
  }
}