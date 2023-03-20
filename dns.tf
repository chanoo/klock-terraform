# dns.tf

resource "aws_route53_zone" "this" {
  name = "klock.app"
}

data "aws_route53_zone" "klock_route53_zone" {
  name = "klock.app."
}
