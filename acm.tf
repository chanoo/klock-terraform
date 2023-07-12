# acm.tf

resource "aws_acm_certificate" "this" {
  domain_name       = "klock.app"
  validation_method = "DNS"
  subject_alternative_names = [
    "api.klock.app",
  ]
  tags = {
    Terraform = "true"
    Environment = "Prod"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "this_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  zone_id = data.aws_route53_zone.klock_route53_zone.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.this_acm_validation : record.fqdn]
}
