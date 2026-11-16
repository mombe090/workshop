<!-- BEGIN_TF_DOCS -->

# This Module is used to create a Virtual Machine in Proxmox

## Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.9.0  |
| <a name="requirement_proxmox"></a> [proxmox](#requirement_proxmox)       | >= 0.68.1 |

## Providers

| Name                                                         | Version   |
| ------------------------------------------------------------ | --------- |
| <a name="provider_proxmox"></a> [proxmox](#provider_proxmox) | >= 0.68.1 |

## Inputs

| Name                                                                                    | Description                                                 | Type           | Default                                | Required |
| --------------------------------------------------------------------------------------- | ----------------------------------------------------------- | -------------- | -------------------------------------- | :------: |
| <a name="input_tags"></a> [tags](#input_tags)                                           | Resource tags                                               | `list(string)` | n/a                                    |   yes    |
| <a name="input_vm_gateway_address"></a> [vm_gateway_address](#input_vm_gateway_address) | Gateway IP address of the VM                                | `string`       | n/a                                    |   yes    |
| <a name="input_vm_id"></a> [vm_id](#input_vm_id)                                        | Id of the Virtual Machine                                   | `number`       | n/a                                    |   yes    |
| <a name="input_vm_ip_address"></a> [vm_ip_address](#input_vm_ip_address)                | IP address of the VM                                        | `string`       | n/a                                    |   yes    |
| <a name="input_vm_name"></a> [vm_name](#input_vm_name)                                  | Name of the virtual machine                                 | `string`       | n/a                                    |   yes    |
| <a name="input_vm_nameservers"></a> [vm_nameservers](#input_vm_nameservers)             | Nameserver IP addresses of the VM                           | `list(string)` | n/a                                    |   yes    |
| <a name="input_vm_search_domain"></a> [vm_search_domain](#input_vm_search_domain)       | Search domain of the VM                                     | `string`       | n/a                                    |   yes    |
| <a name="input_cores"></a> [cores](#input_cores)                                        | Number of CPU cores for this VM                             | `number`       | `4`                                    |    no    |
| <a name="input_description"></a> [description](#input_description)                      | Description of the VM                                       | `string`       | `"Managed by OpenTofu"`                |    no    |
| <a name="input_disk_size"></a> [disk_size](#input_disk_size)                            | Disk size for this VM                                       | `number`       | `20`                                   |    no    |
| <a name="input_memory"></a> [memory](#input_memory)                                     | Amount of memory for this VM                                | `number`       | `4096`                                 |    no    |
| <a name="input_on_boot"></a> [on_boot](#input_on_boot)                                  | Start VM on boot                                            | `bool`         | `true`                                 |    no    |
| <a name="input_pve_node"></a> [pve_node](#input_pve_node)                               | Proxmox node name                                           | `string`       | `"pve"`                                |    no    |
| <a name="input_vm_image_name"></a> [vm_image_name](#input_vm_image_name)                | Name of the image to use, must be /var/lib/vz/template/iso/ | `string`       | `"talos-nocloud-amd64-qemu-agent.img"` |    no    |
| <a name="input_vm_datastore_id"></a> [vm_store_id](#input_vm_datastore_id)              | Storage ID of the VM                                        | `string`       | `"local-lvm"`                          |    no    |

## Outputs

| Name                                                                          | Description                          |
| ----------------------------------------------------------------------------- | ------------------------------------ |
| <a name="output_agent"></a> [agent](#output_agent)                            | Agent enabled                        |
| <a name="output_network_config"></a> [network_config](#output_network_config) | Network configuration of the VM      |
| <a name="output_vm_cpu_count"></a> [vm_cpu_count](#output_vm_cpu_count)       | Number of CPU cores                  |
| <a name="output_vm_disk_size"></a> [vm_disk_size](#output_vm_disk_size)       | Size of the VM disk                  |
| <a name="output_vm_id"></a> [vm_id](#output_vm_id)                            | ID of the VM                         |
| <a name="output_vm_memory"></a> [vm_memory](#output_vm_memory)                | Amount of memory allocated to the VM |
| <a name="output_vm_name"></a> [vm_name](#output_vm_name)                      | Name of the VM                       |

## Modules

No modules.

## Resources

| Name                                                                                                                                    | Type     |
| --------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [proxmox_virtual_environment_vm.this](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |

## Usage Sample

### Virtual Machine creation

```hcl
module "proxmox_vm" {
  source = "../.."

  vm_id   = 100
  vm_name = "talos-linux-vm"

  vm_ip_address      = "192.168.10.11"
  vm_nameservers     = []
  vm_search_domain   = ""
  vm_gateway_address = "192.168.10.1"

  tags = ["talos", "linux"]
}

```

<!-- END_TF_DOCS -->
