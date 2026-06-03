# Hardcoded domain and subdomain
locals {
  domain      = "ceratopurity.com"
  subdomain   = "app"
  full_domain = "${local.subdomain}.${local.domain}"
}

# Create the Hosted Zone for the domain
resource "aws_route53_zone" "main" {
  name = local.domain

  tags = {
    Name        = "${var.project_name}-${var.environment}-zone"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Request an ACM certificate for the full app domain
resource "aws_acm_certificate" "app" {
  domain_name       = local.full_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-cert"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Create DNS validation records in the hosted zone
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.app.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

# Validate the ACM certificate
resource "aws_acm_certificate_validation" "app" {
  certificate_arn         = aws_acm_certificate.app.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# A record for app.ceratopurity.com pointing to the ALB
resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.subdomain
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# HTTPS Listener on the ALB using the validated certificate
resource "aws_lb_listener" "https" {
  load_balancer_arn = var.alb_arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.app.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }
}
