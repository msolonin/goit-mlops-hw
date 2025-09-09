terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}

# ===== IAM role for Lambda functions =====
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Optional: allow Lambda to write logs / metrics elsewhere if needed (CloudWatch).
# Already covered by AWSLambdaBasicExecutionRole.

# ===== Lambda functions =====
resource "aws_lambda_function" "validate" {
  filename         = "${path.module}/lambda/validate.zip"
  function_name    = "${var.project_name}-validate"
  role             = aws_iam_role.lambda_role.arn
  handler          = "validate.lambda_handler"
  runtime          = var.lambda_runtime
  source_code_hash = filebase64sha256("${path.module}/lambda/validate.zip")
}

resource "aws_lambda_function" "log_metrics" {
  filename         = "${path.module}/lambda/log_metrics.zip"
  function_name    = "${var.project_name}-log-metrics"
  role             = aws_iam_role.lambda_role.arn
  handler          = "log_metrics.lambda_handler"
  runtime          = var.lambda_runtime
  source_code_hash = filebase64sha256("${path.module}/lambda/log_metrics.zip")
}

# ===== IAM role for Step Functions =====
resource "aws_iam_role" "sfn_role" {
  name = "${var.project_name}-sfn-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "states.amazonaws.com" }
    }]
  })
}

# Policy allowing Step Functions to invoke Lambdas
data "aws_iam_policy_document" "sfn_invoke_lambdas" {
  statement {
    actions = [
      "lambda:InvokeFunction",
      "lambda:InvokeAsync"
    ]
    resources = [
      aws_lambda_function.validate.arn,
      aws_lambda_function.log_metrics.arn
    ]
  }

  # Allow writing to CloudWatch Logs for the state machine
  statement {
    actions = [
      "logs:CreateLogDelivery",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "sfn_policy" {
  name   = "${var.project_name}-sfn-policy"
  role   = aws_iam_role.sfn_role.id
  policy = data.aws_iam_policy_document.sfn_invoke_lambdas.json
}

# ===== State Machine definition =====
# We use Task states that call Lambda via "arn:aws:states:::lambda:invoke"
locals {
  sfn_definition = jsonencode({
    Comment = "State machine for ML training pipeline: Validate -> LogMetrics"
    StartAt = "ValidateData"
    States = {
      ValidateData = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = aws_lambda_function.validate.arn
          Payload = {
            "source.$" : "$.source",
            "commit.$" : "$.commit",
            "data.$"   : "$.data"
          }
        }
        Next = "LogMetrics"
      }
      LogMetrics = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = aws_lambda_function.log_metrics.arn
          Payload = {
            "validation_result.$" : "$"
          }
        }
        End = true
      }
    }
  })
}

resource "aws_sfn_state_machine" "ml_train_sm" {
  name     = "${var.project_name}-state-machine"
  role_arn = aws_iam_role.sfn_role.arn
  definition = local.sfn_definition
  type     = "STANDARD"
}

# ===== Permissions: allow Step Functions to invoke Lambdas =====
# Lambda needs permission for principal states.amazonaws.com with source ARN = state machine
resource "aws_lambda_permission" "allow_sfn_invoke_validate" {
  statement_id  = "AllowExecutionFromStepFunctions-Validate"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.validate.function_name
  principal     = "states.amazonaws.com"
  source_arn    = aws_sfn_state_machine.ml_train_sm.arn
}

resource "aws_lambda_permission" "allow_sfn_invoke_log_metrics" {
  statement_id  = "AllowExecutionFromStepFunctions-LogMetrics"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_metrics.function_name
  principal     = "states.amazonaws.com"
  source_arn    = aws_sfn_state_machine.ml_train_sm.arn
}

# ===== Outputs =====
output "state_machine_arn" {
  value = aws_sfn_state_machine.ml_train_sm.arn
}

output "validate_lambda_arn" {
  value = aws_lambda_function.validate.arn
}

output "log_metrics_lambda_arn" {
  value = aws_lambda_function.log_metrics.arn
}
