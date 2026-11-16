output "machine_configurations" {
  value       = { for key, config in data.talos_machine_configuration.this : key => config.machine_configuration }
  sensitive   = true
  description = "Rendered machine configurations for all nodes."
}

output "client_configuration" {
  value       = talos_machine_secrets.this.client_configuration
  sensitive   = true
  description = "Talos client configuration object for API access."
}

output "machine_secrets" {
  value       = talos_machine_secrets.this.machine_secrets
  sensitive   = true
  description = "Talos machine secrets used to render machine configurations."
}

output "installer_image" {
  value       = local.installer_image
  description = "Schematic-baked installer image reference (factory.talos.dev/<platform>-installer/<id>:<version>) to patch into UnattendedInstallConfig.installer.image. Null when talos_tools_extensions is empty."
}

output "talos_client_config" {
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
  description = "Talos client configuration in talosconfig format."
}

output "k8s_config" {
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
  description = "Kubernetes client configuration in kubeconfig format."
}

output "k8s_ca_cert" {
  value       = base64decode(yamldecode(talos_cluster_kubeconfig.this.kubeconfig_raw).clusters[0].cluster["certificate-authority-data"])
  sensitive   = true
  description = "PEM-encoded Kubernetes CA certificate from the kubeconfig."
}
