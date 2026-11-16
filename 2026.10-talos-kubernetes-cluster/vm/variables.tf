variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_datastore_id" {
  description = "Proxmox datastore ID"
  type        = string
}

variable "proxmox_assets_datastore_id" {
  description = "Proxmox assets datastore ID, iso/snippet storage"
  type        = string
}

variable "k8s_nodes" {
  description = "Kubernetes cluster nodes configuration"
  type = map(object({
    ip                      = string
    role                    = string
    vm_id                   = number
    host_node               = string
    cores                   = number
    memory                  = number
    disk_size               = number
    install_disk            = optional(string, "/dev/sda")
    longhorn_data_disk      = optional(string)
    tags                    = list(string)
    enable_qemu_guest_agent = optional(bool, true)
  }))
  default = {}
}

variable "talos_tools_extensions" {
  description = "Official Talos system extensions baked into the node image via factory.talos.dev."
  type        = list(string)
  default = [
    "qemu-guest-agent",
    "iscsi-tools",
    "util-linux-tools"
  ]
}

variable "gateway_ip" {
  description = "Default gateway for the homelab network"
  type        = string
  default     = "192.168.10.1"
}

variable "domain" {
  description = "Domain for the homelab (e.g. prod.home.mombesoft.com)"
  type        = string
}

variable "nameservers" {
  description = "List of DNS servers"
  type        = list(string)
  default     = ["192.168.10.111", "192.168.90.113", "192.168.10.1"]
}
