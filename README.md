# Simon's Infrastructure

This is my infrastructure monorepo. It contains all the resources I use to run my personal infrastructure.

## DNS

The DNS module is used to manage the DNS records for my personal infrastructure.

### Usage

```hcl
module "dns" {
  source = "./dns"

  cloudflare_account_id = var.cloudflare_account_id
  cloudflare_email_routing_catch_all_email_address = var.cloudflare_email_routing_catch_all_email_address
}
```

Please also set the CLOUDFLARE_API_TOKEN environment variable to the API token you want to use.