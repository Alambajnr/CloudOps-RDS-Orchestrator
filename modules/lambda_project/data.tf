# 1. THE MAGIC ID CARD - This detects your new account ID automatically
data "aws_caller_identity" "current" {}

# 2. IAM role for Lambda execution
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# 3. Policy for what the Lambda can DO
data "aws_iam_policy_document" "rds_manager_inline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "rds:StopDBInstance",
      "rds:StartDBInstance"
    ]
    resources = [
      # Swapped var.aws_account for the automatic data source
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*",
      "arn:aws:rds:${var.region}:${data.aws_caller_identity.current.account_id}:db:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "rds:DescribeDBInstances"
    ]
    resources = ["*"] # DescribeDBInstances needs "*" to see all DBs
  }
}

# 4. ZIP the code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.py"
  output_path = "${path.module}/lambda/function.zip"
}

# 5. Trust Policy for the Scheduler
data "aws_iam_policy_document" "shedule_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# 6. Policy allowing Scheduler to trigger the Lambda
data "aws_iam_policy_document" "rds_manager_scheduler" {
  statement {
    effect = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = ["arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${local.function_name}"]
  }
}