terraform {
  cloud {
    organization = "queeno"
    workspaces {
      name = "infra-dns"
    }
  }
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

provider "cloudflare" {}
