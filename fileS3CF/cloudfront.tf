locals {
  functionName = "SecureHeaders-${title(var.name)}-${local.environment}"
}

resource "aws_cloudfront_function" "secureHeaders" {
  name    = local.functionName
  runtime = "cloudfront-js-2.0"
  code    = <<EOF
    async function handler(event) {
      const response  = event.response;

      // Just a test for this resource
      response.headers["this-is-a-test"] = { value: "thisComesFromCloudFrontFunctions" };

      return response;
    }
    EOF
}

resource "aws_cloudfront_response_headers_policy" "SecureHeaders" {
  name    = local.functionName
  comment = "Custom security headers attached to response"

  cors_config {
    access_control_allow_methods {
      items = ["GET", "HEAD", "OPTIONS"]
    }

    access_control_allow_headers {
      items = ["origin", "content-type", "accept"]
    }

    access_control_allow_origins {
      items = ["*.${var.dnsHostedZoneName}"]
    }

    access_control_max_age_sec = 600

    access_control_allow_credentials = false

    origin_override = true
  }

  security_headers_config {
    content_security_policy {
      content_security_policy = "default-src 'none'; img-src 'self'; script-src 'self'; style-src 'self'; object-src 'none'"
      override                = true
    }

    strict_transport_security {
      access_control_max_age_sec = 31536000
      override                   = true
      include_subdomains         = true
      preload                    = true
    }

    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }

    referrer_policy {
      referrer_policy = "same-origin"
      override        = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    content_type_options {
      override = true
    }
  }

  custom_headers_config {
    items {
      header   = "createdby"
      override = true
      value    = "Lucas Vinals"
    }

    items {
      header   = "this-is-a-test"
      override = true
      value    = "EstoEsDeCFResponsePolicy"
    }
  }
}

data "aws_cloudfront_cache_policy" "CachingOptimized" {
  id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Import from Managed AWS Policy
}

data "aws_cloudfront_origin_request_policy" "CORS-S3Origin" {
  id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # Import from Managed AWS Policy
}

resource "aws_cloudfront_origin_access_control" "S3" {
  name                              = "S3Access-${title(var.name)}-${local.environment}"
  description                       = "Access to S3 buckets - ${local.environment} environment"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name              = aws_s3_bucket.main.bucket_regional_domain_name
    origin_id                = aws_cloudfront_origin_access_control.S3.name
    origin_access_control_id = aws_cloudfront_origin_access_control.S3.id
  }

  aliases = [local.route53Alias]

  enabled = true

  is_ipv6_enabled = true

  comment = "${title(var.name)} - ${local.environment}"

  default_root_object = var.fileName

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_cloudfront_origin_access_control.S3.name

    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    function_association {
      event_type   = "viewer-response"
      function_arn = aws_cloudfront_function.secureHeaders.arn
    }

    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.CORS-S3Origin.id
    cache_policy_id            = data.aws_cloudfront_cache_policy.CachingOptimized.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.SecureHeaders.id
  }

  http_version = "http2and3"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acmCertificateValidationARN
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # provisioner "local-exec" {
  #   command = "aws cloudfront create-invalidation --distribution-id ${self.id} --paths '/*'"
  # }
}
