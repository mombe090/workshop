locals {
  node_ips            = sort([for node in values(var.nodes) : node.ip])
  control_plane_nodes = sort([for node in values(var.nodes) : node.ip if node.role == "controlplane"])
  worker_nodes        = sort([for node in values(var.nodes) : node.ip if node.role == "worker"])

  # KubeInlineManifestConfig patch documents (Talos >= v1.14 format). Appended
  # only to control-plane machine configs — those are the configs whose
  # manifests Talos uploads at cluster bootstrap.
  inline_manifest_patches = [
    for m in var.cluster_inline_manifests : yamlencode({
      apiVersion = "v1alpha1"
      kind       = "KubeInlineManifestConfig"
      name       = m.name
      manifest   = m.contents
    })
  ]
}
