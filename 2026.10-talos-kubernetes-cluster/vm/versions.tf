terraform {
  required_version = ">= 1.10.0, < 2.0.0"
  backend "s3" {}
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.118.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.12.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = true
  ssh { agent = true }
}
