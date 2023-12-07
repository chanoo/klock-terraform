# klock.resource.s3.tf

resource "aws_s3_bucket" "resource_klock_app_bucket" {
  bucket = "resource.klock.app"
}

resource "aws_s3_account_public_access_block" "resource_klock_app_bucket" {
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "resource_klock_app_bucket_policy" {
  bucket = aws_s3_bucket.resource_klock_app_bucket.id
  policy = data.aws_iam_policy_document.resource_klock_app_bucket.json
}

# AWS ACM 인증서 구성
resource "aws_acm_certificate" "resource_klock_app_bucket_cert" {
  provider                  = aws.useast1
  domain_name               = "*.klock.app"  # 와일드카드 인증서로 변경
  validation_method         = "DNS"
  subject_alternative_names = [
    "resource.klock.app"
  ]
  tags = {
    Terraform = "true"
    Environment = "Prod"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# AWS Route 53 인증서 유효성 검증 레코드
resource "aws_route53_record" "resource_cert_validation" {
  provider = aws.useast1
  for_each = {
    for dvo in aws_acm_certificate.resource_klock_app_bucket_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  zone_id = data.aws_route53_zone.klock_route53_zone.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60

  lifecycle {
    ignore_changes = [records]
  }
}

# AWS ACM 인증서 유효성 검증
resource "aws_acm_certificate_validation" "resource_klock_app_bucket_cert" {
  provider                = aws.useast1
  certificate_arn         = aws_acm_certificate.resource_klock_app_bucket_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.resource_cert_validation : record.fqdn]
}

resource "aws_cloudfront_distribution" "resource_cdn_static_site" {
  provider            = aws.useast1
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "my cloudfront in front of the s3 bucket"

  origin {
    domain_name              = aws_s3_bucket.resource_klock_app_bucket.bucket_regional_domain_name
    origin_id                = "my-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  }

  default_cache_behavior {
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "my-s3-origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.resource_klock_app_bucket_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  aliases = ["resource.klock.app"]
}


data "aws_iam_policy_document" "resource_klock_app_bucket" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.resource_klock_app_bucket.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.resource_cdn_static_site.arn]
    }
  }
}

resource "aws_route53_record" "resource" {
  zone_id = data.aws_route53_zone.klock_route53_zone.id
  name    = "resource.klock.app"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.resource_cdn_static_site.domain_name
    zone_id                = aws_cloudfront_distribution.resource_cdn_static_site.hosted_zone_id
    evaluate_target_health = false
  }
}