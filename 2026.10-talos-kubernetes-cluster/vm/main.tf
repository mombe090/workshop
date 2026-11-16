locals {
  talos_version = "v1.14.5"
}

##################################################
## Talos Kubernetes node VMs
##################################################

data "talos_image_factory_extensions_versions" "this" {
  talos_version = local.talos_version
  filters = {
    names = var.talos_tools_extensions
  }
}

locals {
  talos_image_url   = "https://factory.talos.dev/image/${talos_image_factory_schematic.this.id}/${local.talos_version}/nocloud-amd64.raw.gz"
  talos_image_name  = "talos-${talos_image_factory_schematic.this.id}-${local.talos_version}-nocloud-amd64.img"
  talos_image_nodes = toset([for n in var.k8s_nodes : n.host_node])
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info[*].name
        }
        secureboot = {
          includeWellKnownCertificates = true
        }
      }
    }
  )
}

resource "proxmox_download_file" "talos" {
  for_each = local.talos_image_nodes

  content_type            = "iso"
  datastore_id            = var.proxmox_assets_datastore_id
  node_name               = each.value
  url                     = local.talos_image_url
  file_name               = local.talos_image_name
  decompression_algorithm = "gz"

  # Adopt a copy left behind by an interrupted apply instead of failing; this
  # file is shared by every VM on the host, so it is never per-VM state.
  overwrite           = false
  overwrite_unmanaged = true
}

module "k8s_node_vms" {
  source   = "../../../tf-modules/proxmox-vm"
  for_each = var.k8s_nodes

  id       = each.value.vm_id
  pve_node = each.value.host_node
  name     = each.key

  cores     = each.value.cores
  memory    = each.value.memory
  disk_size = each.value.disk_size

  is_talos_vm      = true
  cloud_image_name = proxmox_download_file.talos[each.value.host_node].file_name

  datastore_id         = var.proxmox_datastore_id
  iso_datastore_id     = var.proxmox_assets_datastore_id
  snippet_datastore_id = var.proxmox_assets_datastore_id

  ip_address      = each.value.ip
  gateway_address = var.gateway_ip
  nameservers     = var.nameservers
  search_domain   = var.domain
  domain          = var.domain

  tags = each.value.tags
}
