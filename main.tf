provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}

data "aws_region" "default" {}

resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose_stream" {
  name        = "${var.kinesis_firehose_stream_name}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn       = "${aws_iam_role.kinesis_firehose_stream_role.arn}"
    bucket_arn     = "${aws_s3_bucket.kinesis_firehose_stream_bucket.arn}"
    buffer_size    = 128
    s3_backup_mode = "Enabled"

    s3_backup_configuration {
      role_arn   = "${aws_iam_role.kinesis_firehose_stream_role.arn}"
      bucket_arn = "${aws_s3_bucket.kinesis_firehose_stream_bucket.arn}"
      prefix     = "${var.kinesis_firehose_stream_backup_prefix}"
    }

    processing_configuration {
      enabled = true

      processors = [{
        type = "Lambda"

        parameters = [{
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.lambda_kinesis_firehose_data_transformation.arn}:$LATEST"
        }]
      }]
    }
  }
}


resource "aws_s3_bucket" "kinesis_firehose_stream_bucket" {
  bucket = "${var.bucket_name}"
  acl    = "private"
}

locals {
  path_prefix = "${var.root_path == true ? path.root : path.module}/functions"
}

data "null_data_source" "lambda_file" {
  inputs {
    filename = "${substr("${local.path_prefix}/${var.lambda_function_file_name}.py", length(path.cwd) + 1, -1)}"
  }
}

data "null_data_source" "lambda_archive" {
  inputs {
    filename = "${substr("${local.path_prefix}/${var.lambda_function_file_name}.zip", length(path.cwd) + 1, -1)}"
  }
}

data "archive_file" "kinesis_firehose_data_transformation" {
  type        = "zip"
  source_file = "${data.null_data_source.lambda_file.outputs.filename}"
  output_path = "${data.null_data_source.lambda_archive.outputs.filename}"
}

resource "aws_lambda_function" "lambda_kinesis_firehose_data_transformation" {
  filename      = "${data.archive_file.kinesis_firehose_data_transformation.0.output_path}"
  function_name = "${var.lambda_function_name}"

  role             = "${aws_iam_role.lambda.arn}"
  handler          = "${var.lambda_function_file_name}.lambda_handler"
  source_code_hash = "${data.archive_file.kinesis_firehose_data_transformation.0.output_base64sha256}"
  runtime          = "python3.6"
  timeout          = 60
}



