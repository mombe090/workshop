# Local values for consistent tag handling
locals {
  sorted_tags = sort(distinct(var.tags))

  # Compute hostname and FQDN safely — avoid doubling the domain.
  # If var.name already ends with ".${var.domain}", strip it for the short hostname
  # and use var.name as-is for the FQDN.  Otherwise, append the domain.
  name_has_domain = var.domain != "" && endswith(var.name, ".${var.domain}")
  hostname        = local.name_has_domain ? trimsuffix(var.name, ".${var.domain}") : var.name
  fqdn            = local.name_has_domain ? var.name : "${var.name}.${var.domain}"
  vm              = proxmox_virtual_environment_vm.this
}

################################################################################################################################
#  Download VM Image from URL to Proxmox Datastore                                                                             #
#  url: https://search.opentofu.org/provider/bpg/proxmox/latest/docs/resources/download_file#example-usage #
################################################################################################################################
resource "proxmox_download_file" "this" {
  count = var.cloud_image_url != null ? 1 : 0

  content_type            = "iso"
  datastore_id            = var.iso_datastore_id
  node_name               = var.pve_node
  url                     = var.cloud_image_url
  file_name               = var.cloud_image_file_name != null ? var.cloud_image_file_name : replace(basename(var.cloud_image_url), ".qcow2", ".img")
  decompression_algorithm = var.cloud_image_decompression_algorithm

  # No URL size checks: upstream images change byte size on every rebuild,
  # which would force replacement on every plan. To pull a new image,
  # taint this resource and re-apply.
  overwrite           = false
  overwrite_unmanaged = true

  lifecycle {
    # Proxmox normalises datastore_id on read-back (e.g. "local" -> "hdd2to")
    # causing a forced replacement on every plan. Ignore it — to intentionally
    # move the image to a different datastore, taint this resource and re-apply.
    ignore_changes = [datastore_id, node_name]
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_file" {
  count = var.use_cloud_init_file && !var.use_user_account ? 1 : 0

  content_type = "snippets"
  datastore_id = var.snippet_datastore_id
  node_name    = var.pve_node

  source_raw {
    data = templatefile("${path.module}/data/cloud_init${var.os_family == "redhat" ? "_redhat" : ""}.yaml.tftpl", {
      timezone                    = var.timezone
      username                    = var.user_config.username
      hostname                    = local.hostname
      fully_qualified_domain_name = local.fqdn
      root_password               = var.user_config.root_password
      user_password               = var.user_config.user_password
      ssh_public_keys             = var.user_config.ssh_public_keys
      ip_address                  = var.ip_address
      gateway                     = var.gateway_address
      nameservers                 = var.nameservers
      search_domain               = var.search_domain
    })

    file_name = "${replace(var.name, "-", "_")}_cloud_init.yaml"
  }

  lifecycle {
    ignore_changes = [
      # Ignore cloud-init data changes to prevent cascading VM replacement.
      # To push new cloud-init content: terraform taint <module>.proxmox_virtual_environment_file.cloud_init_file[0]
      source_raw[0].data,
      # Proxmox normalizes datastore_id on read-back (e.g. "local" -> "hdd2to") causing a perpetual forced replacement.
      datastore_id,
      node_name
    ]

    precondition {
      condition     = var.get_github_keys || length(coalesce(var.user_config.ssh_public_keys, [])) > 0
      error_message = "Either get_github_keys must be true or user_config.ssh_public_keys must not be empty."
    }
  }
}


#######################################################################################################################
# BGP-PROXMOX Provider VM RESOURCE                                                                                    #
# url: https://search.opentofu.org/provider/bpg/proxmox/latest/docs/resources/virtual_environment_vm#example-usage    #
#######################################################################################################################
resource "proxmox_download_file" "installer" {
  count = var.iso_url != null ? 1 : 0

  content_type = "iso"
  datastore_id = var.iso_datastore_id
  node_name    = var.pve_node
  url          = var.iso_url
  file_name    = var.iso_file_name != null ? var.iso_file_name : basename(var.iso_url)

  # Adopt a copy left behind by an interrupted apply instead of failing.
  overwrite           = false
  overwrite_unmanaged = true

  lifecycle {
    ignore_changes = [datastore_id, node_name]
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  vm_id     = var.id
  name      = var.name
  node_name = var.pve_node
  agent {
    enabled = var.enable_qemu_guest_agent
    timeout = "1m"
  }
  description     = var.description
  tags            = local.sorted_tags
  on_boot         = var.on_boot
  stop_on_destroy = true
  protection      = var.protection
  cpu {
    cores = var.cores
    type  = var.cpu_type
  }
  bios    = var.bios
  machine = var.machine_type
  memory {
    dedicated = var.memory
    floating  = var.balloon_minimum
  }
  disk {
    datastore_id = var.datastore_id
    # Plain empty boot disk for ISO-installed VMs (cloud_image_url and
    # cloud_image_name both null); file_id null lets Proxmox create the volume.
    file_id     = var.cloud_image_url != null ? proxmox_download_file.this[0].id : (var.cloud_image_name != null ? "${var.iso_datastore_id}:iso/${var.cloud_image_name}" : null)
    interface   = "virtio0"
    file_format = "raw"
    size        = var.disk_size
    serial      = var.disk_serial
  }
  dynamic "disk" {
    for_each = { for i, d in var.passthrough_disks : i => d }
    iterator = pthru
    content {
      datastore_id      = ""
      interface         = coalesce(pthru.value.interface, "scsi${pthru.key + 1}")
      path_in_datastore = pthru.value.path
      file_format       = "raw"
      backup            = pthru.value.backup
      replicate         = pthru.value.replicate
      serial            = pthru.value.serial
      ssd               = false
    }
  }
  dynamic "efi_disk" {
    for_each = var.enable_efi_disk ? [1] : []
    content {
      datastore_id      = var.datastore_id
      type              = var.efi_disk_type
      pre_enrolled_keys = var.efi_pre_enrolled_keys
    }
  }
  dynamic "initialization" {
    for_each = var.enable_cloud_init ? [1] : []
    content {
      # Talos sees its install disk as /dev/vda; attaching the cloud-init drive
      # via a fixed scsi1 interface would shift device naming, so leave the
      # interface unset for Talos (Proxmox auto-assigns) and pin scsi1 otherwise.
      interface    = var.is_talos_vm ? null : "scsi1"
      datastore_id = var.datastore_id
      ip_config {
        ipv4 {
          address = "${var.ip_address}/24"
          gateway = var.gateway_address
        }
        dynamic "ipv6" {
          for_each = var.is_talos_vm ? [1] : []
          content {
            address = "dhcp"
          }
        }
      }
      dns {
        domain  = var.search_domain
        servers = length(var.nameservers) == 0 ? ["8.8.8.8", "1.1.1.1"] : var.nameservers
      }
      user_data_file_id = var.use_cloud_init_file ? proxmox_virtual_environment_file.cloud_init_file[0].id : null
      dynamic "user_account" {
        for_each = var.use_user_account && !var.use_cloud_init_file ? [1] : []
        content {
          username = var.user_config.username
          password = var.user_config.user_password
          keys     = var.user_config.ssh_public_keys
        }
      }
    }
  }
  dynamic "cdrom" {
    for_each = (var.iso_file_id != null || var.iso_url != null) ? [1] : []
    content {
      file_id   = var.iso_file_id != null ? var.iso_file_id : (var.attach_iso ? proxmox_download_file.installer[0].id : "none")
      interface = var.cdrom_interface
    }
  }
  network_device { bridge = "vmbr0" }
  operating_system {
    type = var.operating_system
  }

  # Only emitted when set: virtio-scsi-pci is the Proxmox default, so passing
  # it explicitly produces no drift on existing VMs.
  scsi_hardware = coalesce(var.scsi_hardware, "virtio-scsi-pci")
  boot_order    = var.boot_order

  # TPM State for SecureBoot support (Talos v1.12+ supports SecureBoot)
  dynamic "tpm_state" {
    for_each = var.enable_tpm ? [1] : []
    content {
      datastore_id = var.tpm_datastore_id != null ? var.tpm_datastore_id : var.datastore_id
      version      = var.tpm_version
    }
  }

  lifecycle {
    ignore_changes = [
      # Sensitive user account changes to prevent forced replacement
      initialization[0].user_account[0].keys,
      initialization[0].user_account[0].password,
      initialization[0].interface,
      initialization[0].datastore_id,
      # Disks are ignored after creation (datastore-id normalization drift on
      # cloned/cloud-init VMs; passthrough disks are attached at create time).
      # To change disks or passthrough_disks later: terraform taint <vm>.
      disk,
      # If you want to ignore DNS server changes (optional):
      initialization[0].dns[0].servers,
      initialization[0].dns[0].domain,
      # If you want to ignore tags changes (optional):
      tags,
      on_boot,
      started,
    ]

    precondition {
      condition     = (var.cloud_image_url != null) != (var.cloud_image_name != null) || (var.cloud_image_url == null && var.cloud_image_name == null && (var.iso_file_id != null || var.iso_url != null))
      error_message = "Set exactly one of cloud_image_url (the module downloads the image) or cloud_image_name (reuse an image already in the ISO datastore), or neither with iso_file_id/iso_url for an ISO-installed VM (plain boot disk)."
    }

    precondition {
      condition     = !(var.iso_file_id != null && var.iso_url != null)
      error_message = "iso_file_id and iso_url are mutually exclusive: reference an existing ISO or have the module download one."
    }
  }
}

#######################################################################################################################
# Guest agent installation via SSH                                                                                    #
# Only applies to cloud-init based VMs: Talos installs the qemu-guest-agent                                           #
# system extension at boot, so there is nothing to provision remotely.                                                #
#######################################################################################################################
resource "terraform_data" "guest_agent" {
  count = var.is_talos_vm || !var.enable_qemu_guest_agent ? 0 : 1

  triggers_replace = {
    vm_id = proxmox_virtual_environment_vm.this.vm_id
  }

  connection {
    type        = "ssh"
    host        = var.ip_address
    user        = var.user_config.username
    private_key = file(pathexpand(var.ssh_private_key_path))
    timeout     = "15m"
    host_key    = ""
  }

  provisioner "file" {
    source      = "${path.module}/data/install_guest_agent.sh"
    destination = "install_guest_agent.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x install_guest_agent.sh",
      "sudo ./install_guest_agent.sh ${var.get_github_keys ? var.user_config.username : ""}"
    ]
  }
}
