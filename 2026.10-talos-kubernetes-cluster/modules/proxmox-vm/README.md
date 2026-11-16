<!-- BEGIN_TF_DOCS -->
# This Module is used to create a Virtual Machine in Proxmox

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | ~> 0.118.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.118.1 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [proxmox_download_file.installer](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/download_file) | resource |
| [proxmox_download_file.this](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/download_file) | resource |
| [proxmox_virtual_environment_file.cloud_init_file](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_file) | resource |
| [proxmox_virtual_environment_vm.this](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |
| [terraform_data.guest_agent](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_attach_iso"></a> [attach\_iso](#input\_attach\_iso) | Whether the downloaded installer ISO is attached as CD-ROM. Set false after installation to keep the ISO in the datastore with an empty drive (current boot order still applies). | `bool` | `true` | no |
| <a name="input_balloon_minimum"></a> [balloon\_minimum](#input\_balloon\_minimum) | Minimum memory in megabytes for ballooning (floating). 0 disables the balloon device. Below memory allows host reclaim; equal to memory only syncs usage stats. | `number` | `0` | no |
| <a name="input_bios"></a> [bios](#input\_bios) | BIOS type for this VM | `string` | `"ovmf"` | no |
| <a name="input_boot_order"></a> [boot\_order](#input\_boot\_order) | Boot device order, e.g. ['ide2', 'virtio0']. Null = Proxmox default. | `list(string)` | `null` | no |
| <a name="input_cdrom_interface"></a> [cdrom\_interface](#input\_cdrom\_interface) | Hardware interface for the CD-ROM (q35 only supports ide0/ide2). | `string` | `"ide2"` | no |
| <a name="input_cloud_image_decompression_algorithm"></a> [cloud\_image\_decompression\_algorithm](#input\_cloud\_image\_decompression\_algorithm) | Decompression algorithm for compressed cloud images, such as gz for Talos Factory raw.gz images. | `string` | `null` | no |
| <a name="input_cloud_image_file_name"></a> [cloud\_image\_file\_name](#input\_cloud\_image\_file\_name) | Override file name for downloaded image (useful when URL ends in .qcow2 which Proxmox rejects — use .img instead) | `string` | `null` | no |
| <a name="input_cloud_image_name"></a> [cloud\_image\_name](#input\_cloud\_image\_name) | File name of an image already present in iso\_datastore\_id, e.g. one downloaded once for many VMs. Mutually exclusive with cloud\_image\_url: use this to avoid every VM downloading the same image. | `string` | `null` | no |
| <a name="input_cloud_image_url"></a> [cloud\_image\_url](#input\_cloud\_image\_url) | URL of the image to download. Mutually exclusive with cloud\_image\_name: set this to have the module download the image for this VM, or leave null and set cloud\_image\_name to reuse an image already in the ISO datastore. | `string` | `null` | no |
| <a name="input_cores"></a> [cores](#input\_cores) | Number of CPU cores for this VM | `number` | `4` | no |
| <a name="input_cpu_type"></a> [cpu\_type](#input\_cpu\_type) | CPU type for this VM | `string` | `"x86-64-v2-AES"` | no |
| <a name="input_datastore_id"></a> [datastore\_id](#input\_datastore\_id) | Storage ID of the VM | `string` | `"local-lvm"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the VM | `string` | `"Managed by OpenTofu"` | no |
| <a name="input_disk_serial"></a> [disk\_serial](#input\_disk\_serial) | Serial number reported by the boot disk. Must be unique per host for guests that disambiguate disks by serial (e.g. TrueNAS). Null = QEMU default (empty). | `string` | `null` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk size for this VM | `number` | `20` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain for the Virtual Machine | `string` | `"changeme!"` | no |
| <a name="input_efi_disk_type"></a> [efi\_disk\_type](#input\_efi\_disk\_type) | EFI disk type for this LxC Container | `string` | `"4m"` | no |
| <a name="input_efi_pre_enrolled_keys"></a> [efi\_pre\_enrolled\_keys](#input\_efi\_pre\_enrolled\_keys) | Enable pre-enrolled UEFI SecureBoot keys (requires SecureBoot-signed OS images) | `bool` | `false` | no |
| <a name="input_enable_cloud_init"></a> [enable\_cloud\_init](#input\_enable\_cloud\_init) | Attach a cloud-init disk and render initialization config. Set false for installer-based VMs (ISO boot) that configure themselves. | `bool` | `true` | no |
| <a name="input_enable_efi_disk"></a> [enable\_efi\_disk](#input\_enable\_efi\_disk) | Enable EFI disk for this LxC Container | `bool` | `true` | no |
| <a name="input_enable_qemu_guest_agent"></a> [enable\_qemu\_guest\_agent](#input\_enable\_qemu\_guest\_agent) | Enable QEMU Guest Agent for enhanced VM management | `bool` | `true` | no |
| <a name="input_enable_tpm"></a> [enable\_tpm](#input\_enable\_tpm) | Enable TPM (Trusted Platform Module) for SecureBoot support | `bool` | `false` | no |
| <a name="input_gateway_address"></a> [gateway\_address](#input\_gateway\_address) | Gateway IP address of the VM | `string` | `"192.168.10.1"` | no |
| <a name="input_get_github_keys"></a> [get\_github\_keys](#input\_get\_github\_keys) | Get public keys from GitHub | `bool` | `true` | no |
| <a name="input_id"></a> [id](#input\_id) | Unique identifier for the virtual machine | `number` | n/a | yes |
| <a name="input_ip_address"></a> [ip\_address](#input\_ip\_address) | IP address of the VM | `string` | n/a | yes |
| <a name="input_is_talos_vm"></a> [is\_talos\_vm](#input\_is\_talos\_vm) | Is this VM for Talos OS | `bool` | `false` | no |
| <a name="input_iso_datastore_id"></a> [iso\_datastore\_id](#input\_iso\_datastore\_id) | Storage ID of the ISO | `string` | `"local"` | no |
| <a name="input_iso_file_id"></a> [iso\_file\_id](#input\_iso\_file\_id) | File ID of an ISO to attach as CD-ROM for installer-based VMs (e.g. 'local:iso/foo.iso', or 'none' for an empty drive). Mutually exclusive with iso\_url. | `string` | `null` | no |
| <a name="input_iso_file_name"></a> [iso\_file\_name](#input\_iso\_file\_name) | Override file name for the downloaded installer ISO (default: basename of iso\_url). | `string` | `null` | no |
| <a name="input_iso_url"></a> [iso\_url](#input\_iso\_url) | URL of an installer ISO downloaded to iso\_datastore\_id and attached as CD-ROM (cloud-init-less installer VMs, e.g. TrueNAS). Mutually exclusive with iso\_file\_id. The download is never overwritten; to pull a new ISO, taint the VM. | `string` | `null` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine type for this VM | `string` | `"q35"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount of memory for this VM | `number` | `4096` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the virtual machine | `string` | n/a | yes |
| <a name="input_nameservers"></a> [nameservers](#input\_nameservers) | Nameserver IP addresses of the VM | `list(string)` | n/a | yes |
| <a name="input_on_boot"></a> [on\_boot](#input\_on\_boot) | Start VM on boot | `bool` | `true` | no |
| <a name="input_operating_system"></a> [operating\_system](#input\_operating\_system) | Operating system for this VM | `string` | `"l26"` | no |
| <a name="input_os_family"></a> [os\_family](#input\_os\_family) | OS family for selecting the correct cloud-init template. Use 'debian' for Debian/Ubuntu and 'redhat' for Fedora/RHEL/CentOS. | `string` | `"debian"` | no |
| <a name="input_passthrough_disks"></a> [passthrough\_disks](#input\_passthrough\_disks) | Host block devices (stable /dev/disk/by-id/ paths) passed through to the VM raw. Empty = no passthrough. `interface` defaults to auto-assigned scsi1..N. Applied at creation; changing the list later requires tainting the VM. | <pre>list(object({<br/>    path      = string<br/>    interface = optional(string)<br/>    backup    = optional(bool, false)<br/>    replicate = optional(bool, false)<br/>    serial    = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_protection"></a> [protection](#input\_protection) | Enable protection for this VM | `bool` | `false` | no |
| <a name="input_pve_node"></a> [pve\_node](#input\_pve\_node) | Proxmox node name | `string` | `"pve"` | no |
| <a name="input_scsi_hardware"></a> [scsi\_hardware](#input\_scsi\_hardware) | SCSI controller hardware type. Null = Proxmox default (virtio-scsi-pci). | `string` | `null` | no |
| <a name="input_search_domain"></a> [search\_domain](#input\_search\_domain) | Search domain of the VM | `string` | n/a | yes |
| <a name="input_snippet_datastore_id"></a> [snippet\_datastore\_id](#input\_snippet\_datastore\_id) | Storage ID of the snippets | `string` | `"local"` | no |
| <a name="input_ssh_private_key_path"></a> [ssh\_private\_key\_path](#input\_ssh\_private\_key\_path) | Path to the private key for the VM | `string` | `"~/.ssh/id_ed25519"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags | `list(string)` | n/a | yes |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Timezone for the Virtual Machine | `string` | `"America/Toronto"` | no |
| <a name="input_tpm_datastore_id"></a> [tpm\_datastore\_id](#input\_tpm\_datastore\_id) | Datastore ID for TPM state storage | `string` | `null` | no |
| <a name="input_tpm_version"></a> [tpm\_version](#input\_tpm\_version) | TPM version (v1.2 or v2.0) | `string` | `"v2.0"` | no |
| <a name="input_use_cloud_init_file"></a> [use\_cloud\_init\_file](#input\_use\_cloud\_init\_file) | Use cloud-init file for this VM | `bool` | `false` | no |
| <a name="input_use_user_account"></a> [use\_user\_account](#input\_use\_user\_account) | Use user account for this VM | `bool` | `false` | no |
| <a name="input_user_config"></a> [user\_config](#input\_user\_config) | Cloud-init configuration file content | <pre>object({<br/>    username        = string<br/>    root_password   = optional(string, null)<br/>    user_password   = optional(string, null)<br/>    ssh_public_keys = optional(list(string), [])<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_agent"></a> [agent](#output\_agent) | Agent enabled |
| <a name="output_network_config"></a> [network\_config](#output\_network\_config) | Network configuration of the VM |
| <a name="output_vm_cpu_count"></a> [vm\_cpu\_count](#output\_vm\_cpu\_count) | Number of CPU cores |
| <a name="output_vm_disk_size"></a> [vm\_disk\_size](#output\_vm\_disk\_size) | Size of the VM disk |
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | ID of the VM |
| <a name="output_vm_memory"></a> [vm\_memory](#output\_vm\_memory) | Amount of memory allocated to the VM |
| <a name="output_vm_name"></a> [vm\_name](#output\_vm\_name) | Name of the VM |

# Usage Sample

## Virtual Machine creation

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