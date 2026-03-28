locals {
  records_altona = yamldecode(file("com.altonalogic-records.yaml"))
}

resource "cloudflare_zone" "altonalogic_com" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "altonalogic.com"

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "altonalogic_com" {
  for_each = { for record in local.records_altona : sha256(jsonencode(record)) => record }

  zone_id = cloudflare_zone.altonalogic_com.id
  name    = each.value.name
  type    = each.value.type
  content = each.value.value
  ttl     = each.value.ttl
  proxied = false
}

resource "cloudflare_bot_management" "altonalogic_com" {
  zone_id            = cloudflare_zone.altonalogic_com.id
  ai_bots_protection = "disabled"
}

resource "cloudflare_email_routing_settings" "altonalogic_com" {
  zone_id = cloudflare_zone.altonalogic_com.id
}

resource "cloudflare_email_routing_catch_all" "altonalogic_com" {
  zone_id = cloudflare_zone.altonalogic_com.id
  actions = [{
    type  = "forward"
    value = [var.cloudflare_email_routing_catch_all_email_address]
  }]
  matchers = [{
    type = "all"
  }]
  name    = "Send to all emails to ${var.cloudflare_email_routing_catch_all_email_address}."
  enabled = true
}

resource "cloudflare_web_analytics_site" "altonalogic_com" {
  account_id   = var.cloudflare_account_id
  zone_tag     = cloudflare_zone.altonalogic_com.id
  auto_install = false
}

output "altona_analytics_token" {
  value       = nonsensitive(cloudflare_web_analytics_site.altonalogic_com.site_token)
  description = "The public token for Cloudflare Web Analytics"
}
