output "talos_client_config" {
  value       = length(module.talos_cluster) > 0 ? module.talos_cluster[0].talos_client_config : null
  sensitive   = true
  description = "Talos client configuration (talosconfig) YAML for cluster API access."
}

output "talos_installer_image" {
  value       = length(module.talos_cluster) > 0 ? module.talos_cluster[0].installer_image : null
  description = "Platform-matched Talos Factory installer reference, including the bootstrap schematic ID."
}

output "k8s_client_config" {
  value       = length(module.talos_cluster) > 0 ? module.talos_cluster[0].k8s_config : null
  sensitive   = true
  description = "Kubernetes kubeconfig YAML generated at bootstrap."
}

output "k8s_endpoint" {
  value       = local.cluster_endpoint
  description = "Kubernetes API endpoint configured for the cluster."
}

output "machine_secrets" {
  value       = length(module.talos_cluster) > 0 ? module.talos_cluster[0].machine_secrets : null
  sensitive   = true
  description = "Talos machine secrets — inputs for the future management root (patches/upgrades)."
}

output "machine_configurations" {
  value       = length(module.talos_cluster) > 0 ? module.talos_cluster[0].machine_configurations : null
  sensitive   = true
  description = "Fully patched machine configuration per node at bootstrap time."
}
