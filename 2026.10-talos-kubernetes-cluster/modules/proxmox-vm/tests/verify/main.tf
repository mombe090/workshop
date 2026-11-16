terraform {
  required_version = ">= 1.10.0"

  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}

variable "node" {
  type = string
}

data "external" "talos_api" {
  program = ["bash", "${path.module}/wait-for-talos.sh", var.node]
}

output "talos_api_reachable" {
  value = data.external.talos_api.result.reachable
}
