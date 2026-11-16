terraform {
  #########################################################################
  #   Required Terraform or OpenTofu version >= 1.9.0 recommended         #
  #########################################################################
  required_version = ">= 1.9.0"

  required_providers {
    #########################################################################
    #   BPG Proxmox provider ~> 0.68 (allows 0.68.x, blocks 0.69+)         #
    #   https://search.opentofu.org/provider/bpg/proxmox/latest             #
    #########################################################################
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.118.0"
    }
  }
}
