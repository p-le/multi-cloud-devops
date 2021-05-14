locals {
  recorder = "${var.organization}-recorder"
  aws_config_bucket = "${var.organization}-aws-configs"
  config_delivery_channel = "${var.organization}-s3"
  iam_role = "${title(var.organization)}ServiceRoleForAWSConfig"
}

# --- IAM Role For AWS Service ---

data "aws_iam_policy_document" "aws_config_iam_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "managed_aws_config_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}


resource "random_id" "aws_config_s3" {
  byte_length = 2
}

resource "aws_iam_role_policy_attachment" "managed_aws_config_role_attach" {
  role       = aws_iam_role.aws_config.name
  policy_arn = data.aws_iam_policy.managed_aws_config_role.arn
}

resource "aws_iam_role" "aws_config" {
  name               = local.iam_role
  path               = "/aws-config/"

  assume_role_policy  = data.aws_iam_policy_document.aws_config_iam_role.json
}

# --- Delivery Channel: S3 ---
resource "aws_s3_bucket" "aws_config_rule_code" {
  bucket =  "${local.aws_config_bucket}-rule-code"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 5
    }
  }
}

resource "aws_s3_bucket" "aws_config" {
  bucket = local.aws_config_bucket

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 5
    }
  }
}

data "aws_iam_policy_document" "allow_aws_config" {
  statement {
    effect    = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions   = [
      "s3:GetBucketAcl",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.aws_config.arn,
      "${aws_s3_bucket.aws_config.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_aws_config_bucket_policy" {
  bucket = aws_s3_bucket.aws_config.id
  policy = data.aws_iam_policy_document.allow_aws_config.json
}


resource "aws_s3_bucket_public_access_block" "aws_config" {
  bucket = aws_s3_bucket.aws_config.id

  block_public_acls   = true
  block_public_policy = true
}

# --- AWS Config Recorder And Delivery Channel ---

resource "aws_config_configuration_recorder" "main" {
  name     = local.recorder
  role_arn = aws_iam_role.aws_config.arn
  recording_group {
    all_supported = true
  }
}

resource "aws_config_configuration_recorder_status" "foo" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true

  depends_on = [
    aws_config_delivery_channel.s3
  ]
}

resource "aws_config_delivery_channel" "s3" {
  name           = local.config_delivery_channel
  s3_bucket_name = aws_s3_bucket.aws_config.bucket
}

# --- AWS Config Rules

# resource "aws_lambda_function" "test" {
#   filename      = "lambda_function_payload.zip"
#   function_name = "lambda_function_name"
#   role          = aws_iam_role.iam_for_lambda.arn
#   handler       = "exports.test"

#   source_code_hash = filebase64sha256("lambda_function_payload.zip")
#   runtime = "python3.8"

#   environment {
#     variables = {
#       foo = "bar"
#     }
#   }
# }

# resource "aws_lambda_permission" "custom" {
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.example.arn
#   principal     = "config.amazonaws.com"
#   statement_id  = "AllowExecutionFromConfig"

#   depends_on = [
#     aws_lambda_permission.example,
#     aws_config_configuration_recorder.foo
#   ]
# }

# resource "aws_config_config_rule" "r" {
#   name = "example"

#   source {
#     owner             = "AWS"
#     source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
#   }

#   depends_on = [
#     aws_lambda_permission.custom,

# }
