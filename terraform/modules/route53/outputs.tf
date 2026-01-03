output "zone_id" {
  description = "Route 53 hosted zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "name_servers" {
  description = "Name servers for the hosted zone (add these to Squarespace)"
  value       = aws_route53_zone.main.name_servers
}

output "domain_name" {
  description = "Full domain name"
  value       = aws_route53_record.app.fqdn
}
