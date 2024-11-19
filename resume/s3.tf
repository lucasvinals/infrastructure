resource "aws_s3_bucket" "resumeOrigin" {
  bucket = local.bucketName
}

resource "aws_s3_bucket_server_side_encryption_configuration" "resumeOrigin" {
  bucket = aws_s3_bucket.resumeOrigin.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "resume" {
  bucket = aws_s3_bucket.resumeOrigin.bucket
  key = var.resumeFileName
  source = "./${path.module}/misc/${var.resumeFileName}"
  content_type = "application/pdf"
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

    resources = [ "${aws_s3_bucket.resumeOrigin.arn}/*" ]

    effect = "Allow"

    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [ "arn:aws:cloudfront::${local.accountId}:distribution/${aws_cloudfront_distribution.resume.id}" ]
    }
  }
}

resource "aws_s3_bucket_policy" "resume" {
  bucket = aws_s3_bucket.resumeOrigin.id
  policy = data.aws_iam_policy_document.CFDistributionAccessToS3Bucket.json
}