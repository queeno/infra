variable "cloudflare_account_id" {
  description = "The Account ID for Cloudflare"
  type        = string
  sensitive   = true
}

variable "cloudflare_email_routing_catch_all_email_address" {
  description = "The email address for the email routing catch all"
  type        = string
  sensitive   = true
}
