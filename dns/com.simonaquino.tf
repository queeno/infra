locals {
  records = yamldecode(file("com.simonaquino-records.yaml"))
}

resource "cloudflare_zone" "simonaquino_com" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "simonaquino.com"

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "simonaquino_com" {
  for_each = { for record in local.records : sha256(jsonencode(record)) => record }

  zone_id = cloudflare_zone.simonaquino_com.id
  name    = each.value.name
  type    = each.value.type
  content = each.value.value
  ttl     = each.value.ttl
  proxied = false
}

resource "cloudflare_bot_management" "simonaquino_com" {
  zone_id            = cloudflare_zone.simonaquino_com.id
  ai_bots_protection = "disabled"
}

resource "cloudflare_email_routing_settings" "simonaquino_com" {
  zone_id = cloudflare_zone.simonaquino_com.id
}

resource "cloudflare_email_routing_catch_all" "simonaquino_com" {
  zone_id = cloudflare_zone.simonaquino_com.id
  actions = [{
    type  = "forward"
    value = [var.cloudflare_email_routing_catch_all_email_address]
  }]
  matchers = [{
    type = "all"
  }]
  enabled = true
  name    = "Send to all emails to ${var.cloudflare_email_routing_catch_all_email_address}."
}

resource "cloudflare_web_analytics_site" "simonaquino_com" {
  account_id   = var.cloudflare_account_id
  zone_tag     = cloudflare_zone.simonaquino_com.id
  auto_install = false
}

output "analytics_token" {
  value       = nonsensitive(cloudflare_web_analytics_site.simonaquino_com.site_token)
  description = "The public token for Cloudflare Web Analytics"
}
