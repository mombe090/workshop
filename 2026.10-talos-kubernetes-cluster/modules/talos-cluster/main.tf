resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}
data "talos_image_factory_extensions_versions" "this" {
  count = length(var.talos_tools_extensions) > 0 ? 1 : 0

  talos_version = var.talos_version
  filters = {
    names = var.talos_tools_extensions
  }
}

resource "talos_image_factory_schematic" "this" {
  count = length(var.talos_tools_extensions) > 0 ? 1 : 0

  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this[count.index].extensions_info[*].name
        }
        secureboot = {
          includeWellKnownCertificates = true
        }
      }
    }
  )
}

locals {
  # OCI image references must be scheme-less; factory_url may carry https://.
  factory_host    = replace(replace(var.factory_url, "https://", ""), "http://", "")
  installer_image = length(var.talos_tools_extensions) > 0 ? "${local.factory_host}/${var.platform}-installer/${talos_image_factory_schematic.this[0].id}:${var.talos_version}" : null

  installer_patch = jsonencode({
    apiVersion = "v1alpha1"
    kind       = "UnattendedInstallConfig"
    installer = {
      image = local.installer_image
    }
    provisioning = {
      diskSelector = {
        match = "disk.dev_path == '/dev/vda'"
      }
    }
  })
}

resource "talos_machine" "this" {
  for_each = var.nodes

  node                            = each.value.ip
  endpoint                        = each.value.ip
  client_configuration            = talos_machine_secrets.this.client_configuration
  machine_configuration           = data.talos_machine_configuration.this[each.key].machine_configuration
  ignore_kubernetes_upgrade_drift = true
  image                           = local.installer_image
  drain_on_upgrade                = false

  timeouts = {
    create = "15m"
    update = "15m"
  }
}

resource "talos_machine_configuration_apply" "this" {
  for_each = var.nodes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.key].machine_configuration
  endpoint                    = each.value.ip
  node                        = each.value.ip

  config_patches = concat(
    [local.installer_patch],
    each.value.config_patches
  )
}

resource "talos_cluster" "this" {
  node                 = var.bootstrap_node
  endpoint             = var.bootstrap_node
  client_configuration = talos_machine_secrets.this.client_configuration
  control_plane_nodes  = local.control_plane_nodes
  kubernetes_version   = var.kubernetes_version

  timeouts = {
    create = "15m"
    update = "15m"
  }

  depends_on = [talos_machine.this]
}

resource "talos_cluster_kubeconfig" "this" {
  node                 = var.bootstrap_node
  endpoint             = var.bootstrap_node
  client_configuration = talos_machine_secrets.this.client_configuration

  depends_on = [talos_cluster.this]
}
