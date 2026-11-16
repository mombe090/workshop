<!-- BEGIN_TF_DOCS -->
# Talos Cluster Bootstrap Module

Bootstraps a Talos Kubernetes cluster on existing nodes. The module does not create Proxmox VMs, download boot images, or deploy platform add-ons.

## Scope

- Applies initial machine configuration with one `talos_machine` per node.
- Bootstraps etcd with exactly one `talos_cluster`.
- Keeps Kubernetes version management with `talos_cluster`.
- Outputs kubeconfig and talosconfig for client access.

Initial hostname, network, and installation-disk configuration can be supplied through each node's `config_patches`. Patches are passed only to `talos_machine_configuration`; they are not duplicated in `talos_machine`.

The module intentionally omits `talos_machine.image`, so it does not manage Talos OS upgrades. `talos_version` pins the machine configuration contract and must not be used as the installed OS version.

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | ~> 0.12.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_talos"></a> [talos](#provider\_talos) | 0.12.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [talos_cluster.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/cluster) | resource |
| [talos_cluster_kubeconfig.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/cluster_kubeconfig) | resource |
| [talos_image_factory_schematic.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/image_factory_schematic) | resource |
| [talos_machine.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine) | resource |
| [talos_machine_configuration_apply.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_secrets.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_secrets) | resource |
| [talos_client_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/client_configuration) | data source |
| [talos_image_factory_extensions_versions.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/image_factory_extensions_versions) | data source |
| [talos_machine_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/machine_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_bootstrap_node"></a> [bootstrap\_node](#input\_bootstrap\_node) | IP address of the control-plane node on which etcd is bootstrapped. | `string` | n/a | yes |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | Kubernetes API endpoint embedded in the machine configuration, for example https://192.168.10.60:6443. | `string` | n/a | yes |
| <a name="input_cluster_inline_manifests"></a> [cluster\_inline\_manifests](#input\_cluster\_inline\_manifests) | Kubernetes manifests applied at cluster bootstrap. Embedded as KubeInlineManifestConfig documents (Talos >= v1.14 format) in control-plane machine configs only. | <pre>list(object({<br/>    name     = string<br/>    contents = string<br/>  }))</pre> | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the Talos cluster. | `string` | n/a | yes |
| <a name="input_factory_url"></a> [factory\_url](#input\_factory\_url) | Talos Image Factory base URL used to resolve extensions and build the schematic-baked installer reference. | `string` | `"https://factory.talos.dev"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version used for bootstrap and managed by talos\_cluster, for example v1.37.0. | `string` | n/a | yes |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | Existing Talos nodes keyed by name. config\_patches contains initial node configuration such as hostname, networking, and install disk. | <pre>map(object({<br/>    ip             = string<br/>    role           = string<br/>    config_patches = optional(list(string), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_talos_tools_extensions"></a> [talos\_tools\_extensions](#input\_talos\_tools\_extensions) | Official Talos system extensions (e.g. qemu-guest-agent, iscsi-tools,<br/>util-linux-tools) baked into the installer image via factory.talos.dev.<br/>The generated machine configuration pins a stock (empty-schematic)<br/>installer image, so extension-bearing nodes MUST override<br/>UnattendedInstallConfig.installer.image with the schematic-baked installer<br/>exposed by the `installer_image` output. | `list(string)` | `[]` | no |
| <a name="input_talos_version"></a> [talos\_version](#input\_talos\_version) | Talos machine configuration contract version used at cluster creation, for example v1.14.0. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_client_configuration"></a> [client\_configuration](#output\_client\_configuration) | Talos client configuration object for API access. |
| <a name="output_installer_image"></a> [installer\_image](#output\_installer\_image) | Schematic-baked installer image reference (factory.talos.dev/<platform>-installer/<id>:<version>) to patch into UnattendedInstallConfig.installer.image. Null when talos\_tools\_extensions is empty. |
| <a name="output_k8s_ca_cert"></a> [k8s\_ca\_cert](#output\_k8s\_ca\_cert) | PEM-encoded Kubernetes CA certificate from the kubeconfig. |
| <a name="output_k8s_config"></a> [k8s\_config](#output\_k8s\_config) | Kubernetes client configuration in kubeconfig format. |
| <a name="output_machine_configurations"></a> [machine\_configurations](#output\_machine\_configurations) | Rendered machine configurations for all nodes. |
| <a name="output_machine_secrets"></a> [machine\_secrets](#output\_machine\_secrets) | Talos machine secrets used to render machine configurations. |
| <a name="output_talos_client_config"></a> [talos\_client\_config](#output\_talos\_client\_config) | Talos client configuration in talosconfig format. |

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
<!-- END_TF_DOCS -->