output "certificate_arn" {
  description = "ARN of the validated ACM certificate"
  value       = aws_acm_certificate.app.arn
}

output "route53_zone_id" {
  description = "Zone ID of the newly created Route53 hosted zone"
  value       = aws_route53_zone.main.zone_id
}

output "app_url" {
  description = "Full URL of the application"
  value       = "https://${local.subdomain}.${local.domain}"
}
