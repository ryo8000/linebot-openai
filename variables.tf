variable "service_name" {
  default     = "LinebotOpenAI"
  description = "this service name"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account id"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy products"
  type        = string
}

variable "line_channel_access_token" {
  description = "line channel access token"
  type        = string
}

variable "line_channel_secret" {
  description = "line channel secret"
  type        = string
}

variable "openai_api_key" {
  description = "project API key of Open AI"
  type        = string
}

variable "lambda_application_log_level" {
  default     = "INFO"
  description = "lambda application log level"
  type        = string
}

variable "lambda_system_log_level" {
  default     = "INFO"
  description = "lambda system log level"
  type        = string
}

variable "lambda_memory_size" {
  default     = 128
  description = "lambda memory size"
  type        = number
}

variable "lambda_runtime" {
  default     = "python3.12"
  description = "lambda runtime"
  type        = string
}

variable "lambda_timeout" {
  default     = 5
  description = "lambda timeout"
  type        = number
}
