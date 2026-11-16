variable "cluster_name" {
  type        = string
  description = "Name of the Talos cluster."

  validation {
    condition     = length(trimspace(var.cluster_name)) > 0
    error_message = "cluster_name must not be empty."
  }
}

variable "talos_tools_extensions" {
  type        = list(string)
  default     = []
  description = <<-EOT
    Official Talos system extensions (e.g. qemu-guest-agent, iscsi-tools,
    util-linux-tools) baked into the installer image via factory.talos.dev.
    The generated machine configuration pins a stock (empty-schematic)
    installer image, so extension-bearing nodes MUST override
    UnattendedInstallConfig.installer.image with the schematic-baked installer
    exposed by the `installer_image` output.
  EOT
}

variable "factory_url" {
  type        = string
  default     = "https://factory.talos.dev"
  description = "Talos Image Factory base URL used to resolve extensions and build the schematic-baked installer reference."
}

variable "platform" {
  type        = string
  default     = "metal"
  description = "Factory platform of the boot media the nodes were installed from (metal = bare metal ISO, nocloud = raw disk image onto Proxmox/QEMU VMs, …). Renders into the schematic installer reference as <platform>-installer/<id>:<version> and MUST match the VM/boot layer — the craftarc Proxmox layer uses nocloud."
}


variable "cluster_endpoint" {
  type        = string
  description = "Kubernetes API endpoint embedded in the machine configuration, for example https://192.168.10.60:6443."

  validation {
    condition     = can(regex("^https://[^[:space:]/]+:[0-9]+$", var.cluster_endpoint))
    error_message = "cluster_endpoint must be an HTTPS URL with an explicit port and no path."
  }
}

variable "talos_version" {
  type        = string
  description = "Talos machine configuration contract version used at cluster creation, for example v1.14.0."

  validation {
    condition     = can(regex("^v?[0-9]+\\.[0-9]+(\\.[0-9]+)?$", var.talos_version))
    error_message = "talos_version must use a version such as v1.14 or v1.14.0."
  }
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version used for bootstrap and managed by talos_cluster, for example v1.37.0."

  validation {
    condition     = can(regex("^v[0-9]+\\.[0-9]+\\.[0-9]+$", var.kubernetes_version))
    error_message = "kubernetes_version must use the full v-prefixed version, such as v1.37.0."
  }
}

variable "bootstrap_node" {
  type        = string
  description = "IP address of the control-plane node on which etcd is bootstrapped."

  validation {
    condition = contains(
      [for node in values(var.nodes) : node.ip if node.role == "controlplane"],
      var.bootstrap_node
    )
    error_message = "bootstrap_node must match the IP address of a control-plane entry in nodes."
  }
}

variable "nodes" {
  type = map(object({
    ip             = string
    role           = string
    config_patches = optional(list(string), [])
  }))
  description = "Existing Talos nodes keyed by name. config_patches contains initial node configuration such as hostname, networking, and install disk."

  validation {
    condition     = length(var.nodes) > 0
    error_message = "At least one node is required."
  }

  validation {
    condition     = alltrue([for node in values(var.nodes) : contains(["controlplane", "worker"], node.role)])
    error_message = "Every node role must be controlplane or worker."
  }

  validation {
    condition     = alltrue([for node in values(var.nodes) : can(cidrhost("${node.ip}/32", 0))])
    error_message = "Every node must use a valid IPv4 address."
  }

  validation {
    condition     = length(distinct([for node in values(var.nodes) : node.ip])) == length(var.nodes)
    error_message = "Node IP addresses must be unique."
  }

  validation {
    condition     = length([for node in values(var.nodes) : node.ip if node.role == "controlplane"]) > 0
    error_message = "At least one control-plane node is required."
  }
}

variable "cluster_inline_manifests" {
  type = list(object({
    name     = string
    contents = string
  }))
  default     = []
  description = "Kubernetes manifests applied at cluster bootstrap. Embedded as KubeInlineManifestConfig documents (Talos >= v1.14 format) in control-plane machine configs only."
}
