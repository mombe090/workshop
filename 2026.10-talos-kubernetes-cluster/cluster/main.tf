locals {
  control_plane_ips = sort([for node in values(var.k8s_nodes) : node.ip if node.role == "controlplane"])
  bootstrap_node    = length(local.control_plane_ips) > 0 ? local.control_plane_ips[0] : ""

  cluster_lb_endpoint = var.load_balancer_ip != null ? "https://${var.load_balancer_ip}:6443" : null
  cluster_endpoint    = coalesce(local.cluster_lb_endpoint, var.cluster_endpoint, length(local.control_plane_ips) > 0 ? "https://${local.control_plane_ips[0]}:6443" : "")

  # kube-apiserver cert SANs from the shared template plus the load balancer.
  api_server_cert_extra_sans = concat(["k8s-cluster.mydomain.io"], var.load_balancer_ip != null ? [var.load_balancer_ip] : [])

  talos_version      = "v1.14.5"
  kubernetes_version = "v1.37.0"

  cluster_nodes = {
    for name, node in var.k8s_nodes : name => {
      ip   = node.ip
      role = node.role
      config_patches = concat(
        [
          templatefile(
            "${path.module}/templates/talos/patches-common-k8s-like-api.yaml",
            {
              hostname               = name
              nameservers            = var.nameservers
              ip                     = node.ip
              gateway                = var.gateway_ip
              network_interface_name = "ens18"
              registry_hostname      = "git.${var.environment}.${var.domain}"
              username               = var.registry_username
              password               = var.registry_password
            }
          )
        ],
        node.role == "controlplane" ?
        [templatefile("${path.module}/templates/talos/controlplane/api-server.yaml.tftpl",
          { cert_extra_sans = local.api_server_cert_extra_sans }
        )] :
        [templatefile("${path.module}/templates/talos/worker/common.yaml", {})],
        []
      )

    }
  }

  # Bootstrap manifests rendered by `just env=<env> gen-inline-manifests`.
  # Every chart in templates/charts.packages.json is embedded as a control-plane
  # inline manifest, using its `name` and `out` fields.
  cluster_inline_manifests = concat([
    for chart in jsondecode(
      file("${path.module}/templates/charts.packages.json")
      ).charts : {
      name     = chart.name
      contents = file("${path.module}/${chart.out}")
    }
    ],
    [
      {
        name     = "vault-auth-reviewer"
        contents = file("${path.root}/templates/k8s/vault-auth-reviewer.yml")
      },
      {
        name     = "namespaces"
        contents = file("${path.root}/templates/k8s/namespaces.yaml")
      },
      {
        name     = "cilium-loadbalancing"
        contents = file("${path.root}/templates/k8s/cilium.loadbalancing.yml")
      }
    ]
  )
}

module "talos_cluster" {
  count  = length(var.k8s_nodes) > 0 ? 1 : 0
  source = "../../../tf-modules/src/talos-cluster"

  cluster_name             = "${var.environment}-k8s-cluster"
  cluster_endpoint         = local.cluster_endpoint
  talos_version            = local.talos_version
  kubernetes_version       = local.kubernetes_version
  bootstrap_node           = local.bootstrap_node
  nodes                    = local.cluster_nodes
  talos_tools_extensions   = var.talos_tools_extensions
  cluster_inline_manifests = local.cluster_inline_manifests

  # Craftarc Proxmox VM layer boots factory nocloud disk images — the installer
  # must be platform-matched (fix: was hardcoded metal-installer).
  platform = "nocloud"
}
