terraform {
  required_version = ">= 1.10.0"

  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}

variable "host" {
  type        = string
  description = "IPv4 address of the Fedora VM"
}

variable "username" {
  type        = string
  description = "Cloud-init user created on the Fedora VM"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Private key matching the public key injected through cloud-init"
  default     = "~/.ssh/id_ed25519"
}

variable "expected_hostname" {
  type        = string
  description = "Hostname that cloud-init must have configured"
}

data "external" "cloud_init" {
  program = [
    "bash",
    "${path.module}/check-cloud-init.sh",
    var.host,
    var.username,
    var.ssh_private_key_path,
    var.expected_hostname,
  ]
}

output "ssh_reachable" {
  value       = data.external.cloud_init.result.ssh_reachable
  description = "Whether SSH key authentication succeeded"
}

output "cloud_init_done" {
  value       = data.external.cloud_init.result.cloud_init_done
  description = "Whether the cloud-init runcmd marker file exists"
}

output "hostname" {
  value       = data.external.cloud_init.result.hostname
  description = "Static hostname reported by the guest"
}

output "guest_agent_active" {
  value       = data.external.cloud_init.result.guest_agent_active
  description = "Whether qemu-guest-agent is active in the guest"
}
