variable "domain_name" {
  description = "Domain name for certificate"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for certificate"
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 zone ID for DNS validation"
  type        = string
}
