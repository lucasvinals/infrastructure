resource "aws_s3_bucket" "main" {
  bucket = local.route53Alias
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "file" {
  bucket = aws_s3_bucket.main.bucket
  key = var.fileName
  source = "./${path.module}/misc/${var.fileName}"
  content_type = local.contentType
}

data aws_caller_identity current {}

data "aws_iam_policy_document" "CFDistributionAccessToS3Bucket" {
  statement {
    sid = "PolicyGetObjectS3Bucket"

    actions = [ "s3:GetObject" ]

    principals {
      type = "Service"
      identifiers = [ "cloudfront.amazonaws.com" ]
    }

    resources = [ "${aws_s3_bucket.main.arn}/*" ]

    effect = "Allow"

    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [ "arn:aws:cloudfront::${local.accountId}:distribution/${aws_cloudfront_distribution.main.id}" ]
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.CFDistributionAccessToS3Bucket.json
}