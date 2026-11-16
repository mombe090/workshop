## Example

```hcl
module "talos_cluster" {
  source = "git::ssh://git@ssh-git.prod.home.mombesoft.com/homelab/tf-modules.git//src/talos-cluster?ref=main"

  cluster_name       = "lab-k8s-cluster"
  cluster_endpoint   = "https://192.168.10.60:6443"
  talos_version      = "v1.14.0"
  kubernetes_version = "v1.37.0"
  bootstrap_node     = "192.168.10.60"

  nodes = {
    lab-cp-01 = {
      ip   = "192.168.10.60"
      role = "controlplane"
    }
    lab-worker-01 = {
      ip   = "192.168.10.70"
      role = "worker"
    }
  }
}

output "kubeconfig" {
  value     = module.talos_cluster.k8s_config
  sensitive = true
}

output "talosconfig" {
  value     = module.talos_cluster.talos_client_config
  sensitive = true
}
```
