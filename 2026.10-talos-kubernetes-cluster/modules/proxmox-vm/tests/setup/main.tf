terraform {
  required_version = ">= 1.10.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.12.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.118.0"
    }
  }
}

locals {
  talos_version  = "v1.14.5"
  fedora_version = "44"
  fedora_build   = "1.7"

  # Test network layout on the lab Proxmox (192.168.90.0/24).
  ip_prefix    = "192.168.90"
  gateway      = "192.168.90.1"
  searchdomain = "mydomain.io"
}

###############################################################################
# Unique per-run identifiers so leftover ISO downloads from a failed run do   #
# not collide with the next run (proxmox_download_file uses overwrite=false).  #
###############################################################################
resource "random_id" "this" {
  byte_length = 4
}

resource "random_integer" "talos" {
  min = 223
  max = 229
}

# Second Talos VM that boots the image downloaded by the first one, to cover
# the cloud_image_name (pre-downloaded image) path.
resource "random_integer" "talos_shared" {
  min = 237
  max = 243
}

resource "random_integer" "fedora" {
  min = 230
  max = 236
}

resource "random_pet" "talos" {
  length = 2
  prefix = "tftest-talos"
}

resource "random_pet" "talos_shared" {
  length = 2
  prefix = "tftest-talos-shared"
}

resource "random_pet" "fedora" {
  length = 2
  prefix = "tftest-fedora"
}

# Talos Factory image with the qemu-guest-agent extension baked in, so the
# agent is available once the node leaves maintenance mode.
resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = ["siderolabs/qemu-guest-agent"]
      }
    }
  })
}

# Keep a separately managed image available for the cloud_image_name test run.
# Terraform test runs have isolated states, so that run cannot rely on the
# image downloaded by create_talos_vm.
resource "proxmox_download_file" "talos_shared" {
  content_type            = "iso"
  datastore_id            = "local"
  node_name               = "pve"
  url                     = "https://factory.talos.dev/image/${talos_image_factory_schematic.this.id}/${local.talos_version}/nocloud-amd64.raw.gz"
  file_name               = "tftest-shared-${random_id.this.hex}-${local.talos_version}-nocloud-amd64.img"
  decompression_algorithm = "gz"
  overwrite               = false
  overwrite_unmanaged     = true
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key injected into the Fedora cloud-init user-data"
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to the SSH private key used by the module guest-agent provisioner and the cloud-init verifier"
  default     = "~/.ssh/id_ed25519"
}

output "talos_vm_id" {
  value = 900000 + random_integer.talos.result
}

output "talos_vm_name" {
  value = random_pet.talos.id
}

output "talos_ip_address" {
  value = "${local.ip_prefix}.${random_integer.talos.result}"
}

output "talos_shared_vm_id" {
  value = 900000 + random_integer.talos_shared.result
}

output "talos_shared_vm_name" {
  value = random_pet.talos_shared.id
}

output "talos_shared_ip_address" {
  value = "${local.ip_prefix}.${random_integer.talos_shared.result}"
}

output "talos_shared_image_file_name" {
  value = proxmox_download_file.talos_shared.file_name
}

output "talos_image_url" {
  value = "https://factory.talos.dev/image/${talos_image_factory_schematic.this.id}/${local.talos_version}/nocloud-amd64.raw.gz"
}

output "talos_image_file_name" {
  value = "tftest-talos-${substr(talos_image_factory_schematic.this.id, 0, 8)}-${random_id.this.hex}-${local.talos_version}-nocloud-amd64.img"
}

output "fedora_vm_id" {
  value = 910000 + random_integer.fedora.result
}

output "fedora_vm_name" {
  value = random_pet.fedora.id
}

output "fedora_ip_address" {
  value = "${local.ip_prefix}.${random_integer.fedora.result}"
}

output "fedora_image_url" {
  value = "https://download.fedoraproject.org/pub/fedora/linux/releases/${local.fedora_version}/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-${local.fedora_version}-${local.fedora_build}.x86_64.qcow2"
}

output "fedora_image_file_name" {
  value = "tftest-fedora-${local.fedora_version}-${random_id.this.hex}.img"
}

output "gateway_address" {
  value = local.gateway
}

output "search_domain" {
  value = local.searchdomain
}

output "ssh_public_key" {
  value = trimspace(file(pathexpand(var.ssh_public_key_path)))
}

output "ssh_private_key_path" {
  value = var.ssh_private_key_path
}
