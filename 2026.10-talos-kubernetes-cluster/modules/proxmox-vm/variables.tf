# VM Identity Variables
variable "id" {
  type        = number
  description = "Unique identifier for the virtual machine"
}

variable "name" {
  type        = string
  description = "Name of the virtual machine"
}

variable "description" {
  type        = string
  description = "Description of the VM"
  default     = "Managed by OpenTofu"
}

variable "tags" {
  type        = list(string)
  description = "Resource tags"
}


# VM Storage and Image Configuration
variable "datastore_id" {
  type        = string
  description = "Storage ID of the VM"
  default     = "local-lvm"
}

variable "disk_size" {
  type        = number
  description = "Disk size for this VM"
  default     = 20
}

variable "enable_efi_disk" {
  type        = bool
  description = "Enable EFI disk for this LxC Container"
  default     = true
}

variable "efi_disk_type" {
  type        = string
  description = "EFI disk type for this LxC Container"
  default     = "4m"
}

variable "enable_tpm" {
  type        = bool
  description = "Enable TPM (Trusted Platform Module) for SecureBoot support"
  default     = false
}

variable "enable_qemu_guest_agent" {
  type        = bool
  description = "Enable QEMU Guest Agent for enhanced VM management"
  default     = true
}

variable "tpm_datastore_id" {
  type        = string
  description = "Datastore ID for TPM state storage"
  default     = null
}

variable "tpm_version" {
  type        = string
  description = "TPM version (v1.2 or v2.0)"
  default     = "v2.0"
  validation {
    condition     = contains(["v1.2", "v2.0"], var.tpm_version)
    error_message = "TPM version must be either 'v1.2' or 'v2.0'"
  }
}

variable "efi_pre_enrolled_keys" {
  type        = bool
  description = "Enable pre-enrolled UEFI SecureBoot keys (requires SecureBoot-signed OS images)"
  default     = false
}

variable "iso_datastore_id" {
  type        = string
  description = "Storage ID of the ISO"
  default     = "local"
}

variable "snippet_datastore_id" {
  type        = string
  description = "Storage ID of the snippets"
  default     = "local"
}


# VM Cloud Image Configuration
variable "cloud_image_url" {
  type        = string
  description = "URL of the image to download. Mutually exclusive with cloud_image_name: set this to have the module download the image for this VM, or leave null and set cloud_image_name to reuse an image already in the ISO datastore."
  default     = null
}

variable "cloud_image_file_name" {
  type        = string
  description = "Override file name for downloaded image (useful when URL ends in .qcow2 which Proxmox rejects — use .img instead)"
  default     = null
}

variable "cloud_image_decompression_algorithm" {
  type        = string
  description = "Decompression algorithm for compressed cloud images, such as gz for Talos Factory raw.gz images."
  default     = null

  validation {
    condition     = var.cloud_image_decompression_algorithm == null || contains(["bz2", "gz", "lzo", "zst"], var.cloud_image_decompression_algorithm)
    error_message = "cloud_image_decompression_algorithm must be bz2, gz, lzo, zst, or null."
  }
}

variable "os_family" {
  type        = string
  description = "OS family for selecting the correct cloud-init template. Use 'debian' for Debian/Ubuntu and 'redhat' for Fedora/RHEL/CentOS."
  default     = "debian"
  validation {
    condition     = contains(["debian", "redhat"], var.os_family)
    error_message = "os_family must be either 'debian' or 'redhat'."
  }
}

variable "cloud_image_name" {
  type        = string
  description = "File name of an image already present in iso_datastore_id, e.g. one downloaded once for many VMs. Mutually exclusive with cloud_image_url: use this to avoid every VM downloading the same image."
  default     = null
}

# VM Network Configuration
variable "domain" {
  description = "Domain for the Virtual Machine"
  type        = string
  default     = "changeme!"
}

variable "gateway_address" {
  type        = string
  description = "Gateway IP address of the VM"
  default     = "192.168.10.1"
}

variable "ip_address" {
  type        = string
  description = "IP address of the VM"
}

variable "nameservers" {
  type        = list(string)
  description = "Nameserver IP addresses of the VM"
}

variable "search_domain" {
  type        = string
  description = "Search domain of the VM"
}


# Operating System and Linux Configuration
variable "protection" {
  type        = bool
  description = "Enable protection for this VM"
  default     = false
}

variable "on_boot" {
  type        = bool
  description = "Start VM on boot"
  default     = true
}

variable "pve_node" {
  type        = string
  description = "Proxmox node name"
  default     = "pve"
}

variable "cores" {
  type        = number
  description = "Number of CPU cores for this VM"
  default     = 4
}

variable "cpu_type" {
  type        = string
  description = "CPU type for this VM"
  default     = "x86-64-v2-AES"
}

variable "memory" {
  type        = number
  description = "Amount of memory for this VM"
  default     = 4096
}

variable "balloon_minimum" {
  type        = number
  description = "Minimum memory in megabytes for ballooning (floating). 0 disables the balloon device. Below memory allows host reclaim; equal to memory only syncs usage stats."
  default     = 0

  validation {
    condition     = var.balloon_minimum >= 0
    error_message = "balloon_minimum must be zero or positive."
  }
}

variable "bios" {
  type        = string
  description = "BIOS type for this VM"
  default     = "ovmf"
}

variable "machine_type" {
  type        = string
  description = "Machine type for this VM"
  default     = "q35"
}

variable "operating_system" {
  type        = string
  description = "Operating system for this VM"
  default     = "l26" #Windows win11
}

variable "timezone" {
  description = "Timezone for the Virtual Machine"
  type        = string
  default     = "America/Toronto"
}


# User Configuration
variable "ssh_private_key_path" {
  type        = string
  description = "Path to the private key for the VM"
  default     = "~/.ssh/id_ed25519"
}

variable "use_cloud_init_file" {
  type        = bool
  description = "Use cloud-init file for this VM"
  default     = false
}

variable "use_user_account" {
  type        = bool
  description = "Use user account for this VM"
  default     = false

  validation {
    condition     = !var.use_cloud_init_file || !var.use_user_account
    error_message = "When use_cloud_init_file is true, use_user_account must be false."
  }
}

variable "user_config" {
  type = object({
    username        = string
    root_password   = optional(string, null)
    user_password   = optional(string, null)
    ssh_public_keys = optional(list(string), [])
  })
  description = "Cloud-init configuration file content"
  sensitive   = true
  default     = null
}

variable "get_github_keys" {
  type        = bool
  description = "Get public keys from GitHub"
  default     = true
}

variable "is_talos_vm" {
  type        = bool
  description = "Is this VM for Talos OS"
  default     = false
}

# ISO-installed VMs (no cloud image, no cloud-init)
variable "iso_file_id" {
  type        = string
  description = "File ID of an ISO to attach as CD-ROM for installer-based VMs (e.g. 'local:iso/foo.iso', or 'none' for an empty drive). Mutually exclusive with iso_url."
  default     = null
}

variable "iso_url" {
  type        = string
  description = "URL of an installer ISO downloaded to iso_datastore_id and attached as CD-ROM (cloud-init-less installer VMs, e.g. TrueNAS). Mutually exclusive with iso_file_id. The download is never overwritten; to pull a new ISO, taint the VM."
  default     = null
}

variable "iso_file_name" {
  type        = string
  description = "Override file name for the downloaded installer ISO (default: basename of iso_url)."
  default     = null
}

variable "attach_iso" {
  type        = bool
  description = "Whether the downloaded installer ISO is attached as CD-ROM. Set false after installation to keep the ISO in the datastore with an empty drive (current boot order still applies)."
  default     = true
}

variable "cdrom_interface" {
  type        = string
  description = "Hardware interface for the CD-ROM (q35 only supports ide0/ide2)."
  default     = "ide2"
}

variable "boot_order" {
  type        = list(string)
  description = "Boot device order, e.g. ['ide2', 'virtio0']. Null = Proxmox default."
  default     = null
}

variable "scsi_hardware" {
  type        = string
  description = "SCSI controller hardware type. Null = Proxmox default (virtio-scsi-pci)."
  default     = null
  validation {
    condition     = var.scsi_hardware == null || contains(["lsi", "lsi53c810", "virtio-scsi-pci", "virtio-scsi-single", "megasas", "pvscsi"], var.scsi_hardware)
    error_message = "scsi_hardware must be one of lsi, lsi53c810, virtio-scsi-pci, virtio-scsi-single, megasas, pvscsi, or null."
  }
}

variable "enable_cloud_init" {
  type        = bool
  description = "Attach a cloud-init disk and render initialization config. Set false for installer-based VMs (ISO boot) that configure themselves."
  default     = true
}

variable "disk_serial" {
  type        = string
  description = "Serial number reported by the boot disk. Must be unique per host for guests that disambiguate disks by serial (e.g. TrueNAS). Null = QEMU default (empty)."
  default     = null
}

# Host disk passthrough
variable "passthrough_disks" {
  type = list(object({
    path      = string
    interface = optional(string)
    backup    = optional(bool, false)
    replicate = optional(bool, false)
    serial    = optional(string)
  }))
  description = "Host block devices (stable /dev/disk/by-id/ paths) passed through to the VM raw. Empty = no passthrough. `interface` defaults to auto-assigned scsi1..N. Applied at creation; changing the list later requires tainting the VM."
  default     = []

  validation {
    condition     = alltrue([for d in var.passthrough_disks : startswith(d.path, "/dev/disk/by-id/")])
    error_message = "passthrough_disks paths must use stable /dev/disk/by-id/ paths."
  }
}
