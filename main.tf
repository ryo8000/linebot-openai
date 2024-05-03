terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.service_name}-api"
  description = "API invoked from Line"
  tags = {
    Service = var.service_name
  }
}

resource "aws_api_gateway_resource" "linebot_resource" {
  path_part   = "linebot"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.linebot_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.linebot_resource.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_replier.invoke_arn
}

# IAM
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_replier_role" {
  name               = "${var.service_name}-replier-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  description        = "Lambda role for ${var.service_name}-replier"
  tags = {
    Service = var.service_name
  }
}

resource "aws_iam_role_policy" "lambda_replier_role_policy" {
  name = "${var.service_name}ReplierPolicy"
  role = aws_iam_role.lambda_replier_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "Statement0",
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

# Lambda
data "archive_file" "lambda_layer_zip" {
  type        = "zip"
  source_dir  = "build/layers/${var.service_name}"
  output_path = "dist/lambda/layer_${var.service_name}_payload.zip"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name          = "${var.service_name}-layer"
  filename            = data.archive_file.lambda_layer_zip.output_path
  compatible_runtimes = [var.lambda_runtime]
}

data "archive_file" "lambda_function_zip" {
  type        = "zip"
  source_dir  = "src"
  output_path = "dist/lambda/function_payload.zip"
}

resource "aws_lambda_function" "lambda_replier" {
  function_name    = "${var.service_name}-replier"
  filename         = data.archive_file.lambda_function_zip.output_path
  source_code_hash = data.archive_file.lambda_function_zip.output_base64sha256
  description      = "reply message"
  environment {
    variables = {
      LINE_CHANNEL_ACCESS_TOKEN = var.line_channel_access_token
      LINE_CHANNEL_SECRET       = var.line_channel_secret
      OPENAI_API_KEY            = var.openai_api_key
    }
  }
  handler = "replier.lambda_handler"
  layers  = [aws_lambda_layer_version.lambda_layer.arn]
  logging_config {
    log_format            = "JSON"
    application_log_level = var.lambda_application_log_level
    system_log_level      = var.lambda_system_log_level
  }
  memory_size = var.lambda_memory_size
  role        = aws_iam_role.lambda_replier_role.arn
  runtime     = var.lambda_runtime
  timeout     = var.lambda_timeout
  tags = {
    Service = var.service_name
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_replier.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.post_method.http_method}${aws_api_gateway_resource.linebot_resource.path}"
}
