locals {
  records_pragmalogica = yamldecode(file("com.pragmalogica-records.yaml"))
}

import {
  id = "3879d480e5864134c6d5ccbb6bd71728"
  to = cloudflare_zone.pragmalogica_com
}

resource "cloudflare_zone" "pragmalogica_com" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "pragmalogica.com"

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "pragmalogica_com" {
  for_each = { for record in local.records_pragmalogica : sha256(jsonencode(record)) => record }

  zone_id = cloudflare_zone.pragmalogica_com.id
  name    = each.value.name
  type    = each.value.type
  content = each.value.value
  ttl     = each.value.ttl
  proxied = false
}

resource "cloudflare_bot_management" "pragmalogica_com" {
  zone_id            = cloudflare_zone.pragmalogica_com.id
  ai_bots_protection = "disabled"
}

resource "cloudflare_email_routing_settings" "pragmalogica_com" {
  zone_id = cloudflare_zone.pragmalogica_com.id
}

resource "cloudflare_email_routing_catch_all" "pragmalogica_com" {
  zone_id = cloudflare_zone.pragmalogica_com.id
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

resource "cloudflare_web_analytics_site" "pragmalogica_com" {
  account_id   = var.cloudflare_account_id
  zone_tag     = cloudflare_zone.pragmalogica_com.id
  auto_install = false
}

output "pragmalogica_analytics_token" {
  value       = nonsensitive(cloudflare_web_analytics_site.pragmalogica_com.site_token)
  description = "The public token for Cloudflare Web Analytics"
}
