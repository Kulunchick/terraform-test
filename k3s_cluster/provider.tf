terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "~> 1.45"
    }

    ansible = {
      version = "1.3.0"
      source  = "ansible/ansible"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}
