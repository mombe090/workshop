data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = local.node_ips
  endpoints            = local.control_plane_nodes
}

data "talos_machine_configuration" "this" {
  for_each = var.nodes

  cluster_name       = var.cluster_name
  machine_type       = each.value.role
  cluster_endpoint   = var.cluster_endpoint
  kubernetes_version = var.kubernetes_version
  talos_version      = var.talos_version
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  config_patches = each.value.role == "controlplane" ? concat(
    each.value.config_patches,
    local.inline_manifest_patches,
  ) : each.value.config_patches
}
