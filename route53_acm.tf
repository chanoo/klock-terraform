resource "aws_route53_zone" "klock" {
  name = var.domain_name
}

locals {
  all_domain_names = concat([var.domain_name], formatlist("%s.%s", var.subdomain_names, var.domain_name))
}

resource "aws_acm_certificate" "klock" {
  domain_name       = var.domain_name
  subject_alternative_names = local.all_domain_names
  validation_method = "DNS"

  tags = {
    Terraform = "true"
  }
}

resource "aws_route53_record" "klock_validation" {
  for_each = {
    for dvo in aws_acm_certificate.klock.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  type    = each.value.type
  zone_id = aws_route53_zone.klock.zone_id
  ttl     = "60"
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "klock" {
  certificate_arn         = aws_acm_certificate.klock.arn
  validation_record_fqdns = [for record in aws_route53_record.klock_validation : record.fqdn]
}

resource "aws_route53_record" "klock" {
  for_each = var.target_domains

  zone_id = aws_route53_zone.klock.zone_id
  name    = "${each.key}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = each.value
    zone_id                = var.target_zone_ids[each.key]
    evaluate_target_health = false
  }
}
