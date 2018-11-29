variable "aws_access_key" {
   default = "AKIAJA3P"
}


variable "aws_secret_key" {
   default = "cCJQDB7EzP"
}

variable "region" {
  description = "AWS region"
  default     = ""
}

variable "kinesis_firehose_stream_name" {
  description = "Name to be use on kinesis firehose stream"
}

variable "kinesis_firehose_stream_backup_prefix" {
  description = "The prefix name to use for the kinesis backup"
  default     = "backup"
}

variable "root_path" {
  description = "The path where the lambda function file is located is root or module path"
  default     = false
}

variable "bucket_name" {
  description = "The bucket name"
}

variable "lambda_function_name" {
  description = "The lambda function name"
}

variable "lambda_function_file_name" {
  description = "The lambda function file name"
}

