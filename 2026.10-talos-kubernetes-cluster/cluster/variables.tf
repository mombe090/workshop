variable "environment" {
  type        = string
  description = "Target environment (lab, dev, prod). Used for cluster naming and backend state."

  validation {
    condition     = contains(["lab", "dev", "prod"], var.environment)
    error_message = "environment must be lab, dev, or prod."
  }
}

variable "domain" {
 type = string
 description = "Search domain"
}
variable "k8s_nodes" {
  type = map(object({
    ip                 = string
    role               = string
    install_disk       = optional(string, "/dev/vda")
    longhorn_data_disk = optional(string, null)
  }))
  description = "Existing Talos nodes provisioned by the craftarc VM layer (iac/terraform), keyed by node name. An empty map disables bootstrap — plans are no-ops until nodes are wired."
  validation {
    condition     = var.k8s_nodes == {} || length(distinct([for node in values(var.k8s_nodes) : node.ip])) == length(var.k8s_nodes)
    error_message = "Node IP addresses must be unique."
  }

  validation {
    condition     = var.k8s_nodes == {} || alltrue([for node in values(var.k8s_nodes) : node.role != "" && node.install_disk != ""])
    error_message = "Every node must declare a role and an install_disk."
  }

  validation {
    condition     = var.k8s_nodes == {} || length([for node in values(var.k8s_nodes) : node if node.role == "controlplane"]) > 0
    error_message = "At least one control-plane node is required when k8s_nodes is non-empty."
  }
}

variable "cluster_endpoint" {
  type        = string
  default     = null
  description = "Kubernetes API endpoint embedded in the machine configuration, for example https://192.168.10.82:6443. Defaults to the first control-plane node IP with port 6443."
}

variable "load_balancer_ip" {
  type        = string
  default     = null
  description = "IP of the external TCP load balancer fronting the control-plane nodes (HAProxy). When set, it wins the cluster endpoint over cluster_endpoint and is added to the kube-apiserver cert SANs."
}

variable "talos_tools_extensions" {
  type        = list(string)
  default     = ["qemu-guest-agent", "iscsi-tools", "util-linux-tools"]
  description = "Official Talos system extensions baked into the installer image (factory.talos.dev schematic). Must match the extension set used for the boot ISO in craftarc (same content hash)."

  validation {
    condition = alltrue([
      for ext in var.talos_tools_extensions : contains(["qemu-guest-agent", "iscsi-tools", "util-linux-tools", "trident-iscsi-tools"], ext)
    ])
    error_message = "Unsupported extension; extend the allowlist with the factory.talos.dev extension name."
  }
}

variable "gateway_ip" {
  type        = string
  default     = null
  description = "Gateway used in each node's initial network configuration. Required when k8s_nodes is non-empty."
  validation {
    condition     = var.k8s_nodes == {} || var.gateway_ip != null
    error_message = "gateway_ip must be set when k8s_nodes is non-empty."
  }
}

variable "nameservers" {
  type        = list(string)
  default     = []
  description = "DNS servers used in each node's initial network configuration. Required when k8s_nodes is non-empty."

  validation {
    condition     = var.k8s_nodes == {} || length(var.nameservers) > 0
    error_message = "nameservers must be set when k8s_nodes is non-empty."
  }
}

variable "registry_username" {
  type = string
  description = "forgejo registry username"
}

variable "registry_password" {
  type = string
  description = "forgejo registry password"
  sensitive = true
}

