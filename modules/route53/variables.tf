variable "domain_name" {
  description = "Domain name (e.g., example.com)"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for the application"
  type        = string
  default     = ""
}

variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "Zone ID of the ALB"
  type        = string
}
