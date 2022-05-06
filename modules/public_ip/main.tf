terraform {
  required_providers {
    publicip = {
      source  = "nxt-engineering/publicip"
      version = "~> 0.0.3"
    }
  }
}

data "publicip_address" "main" {}

output "ip" {
  value = data.publicip_address.main.ip
}

output "all" {
  value = data.publicip_address.main
}