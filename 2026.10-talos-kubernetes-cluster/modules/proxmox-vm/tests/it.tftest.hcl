# Integration tests for src/proxmox/vm against the lab Proxmox host.
#
# Covers three boot paths:
#   - Talos: nocloud raw image streamed from Talos Factory, static IP, API
#     reachable in maintenance mode.
#   - Talos sharing a pre-downloaded image via cloud_image_name (no URL).
#   - Fedora: cloud-init snippet (os_family = "redhat"), SSH key auth, cloud-init
#     runcmd completion, hostname and qemu-guest-agent.
#
# Run with `just test` from src/proxmox/vm (copies tests/ to
# .terraform.tfvars.d/ and executes `terraform test -test-directory`).
#
# Prerequisites:
#   - ~/.ssh/id_ed25519(.pub) present
#   - talosctl on PATH
#   - "snippets" content type enabled on the ISO datastore (local)
#   - 192.168.90.223-243 free

provider "proxmox" {
  endpoint = "https://192.168.90.195:8006/"
  insecure = true

  ssh {
    agent = true
  }
}

run "setup" {
  module {
    source = "./tests/setup"
  }
}

###############################################################################
# Talos                                                                       #
###############################################################################

run "create_talos_vm" {
  variables {
    id       = run.setup.talos_vm_id
    name     = run.setup.talos_vm_name
    pve_node = "pve"

    is_talos_vm = true
    on_boot     = false
    cores       = 2
    memory      = 2048
    disk_size   = 20

    datastore_id         = "local-lvm"
    iso_datastore_id     = "local"
    snippet_datastore_id = "local"

    cloud_image_url                     = run.setup.talos_image_url
    cloud_image_file_name               = run.setup.talos_image_file_name
    cloud_image_decompression_algorithm = "gz"

    ip_address      = run.setup.talos_ip_address
    gateway_address = run.setup.gateway_address
    nameservers     = [run.setup.gateway_address]
    domain          = run.setup.search_domain
    search_domain   = run.setup.search_domain

    tags = ["talos", "integration-test"]
  }

  assert {
    condition     = tostring(output.vm_id) == tostring(run.setup.talos_vm_id)
    error_message = "The Talos VM output must expose the created VM ID."
  }

  assert {
    condition     = output.vm_name == run.setup.talos_vm_name
    error_message = "The Talos VM output must expose the created VM name."
  }

  assert {
    condition     = output.vm_cpu_count == 2 && output.vm_memory == 2048
    error_message = "The Talos VM outputs must expose the configured compute resources."
  }

  assert {
    condition     = output.network_config.ip_address == "${run.setup.talos_ip_address}/24"
    error_message = "The Talos VM output must expose the configured static IP address."
  }

  assert {
    condition     = output.agent == true
    error_message = "The QEMU agent must be enabled from first boot (Talos ships the qemu-guest-agent extension)."
  }
}

run "verify_talos_api" {
  module {
    source = "./tests/verify"
  }

  variables {
    node = trimsuffix(run.create_talos_vm.network_config.ip_address, "/24")
  }

  assert {
    condition     = output.talos_api_reachable == "true"
    error_message = "The Talos API must be reachable in maintenance mode on the VM static IP."
  }
}

###############################################################################
# Talos reusing a pre-downloaded image (cloud_image_name, no URL)             #
###############################################################################

# Boots a file downloaded once by the setup run, using only its name. This is
# the path callers use to download one image per host and share it across
# nodes, instead of every VM module instance downloading the same file.
run "create_talos_vm_shared_image" {
  variables {
    id       = run.setup.talos_shared_vm_id
    name     = run.setup.talos_shared_vm_name
    pve_node = "pve"

    is_talos_vm = true
    on_boot     = false
    cores       = 2
    memory      = 2048
    disk_size   = 20

    datastore_id         = "local-lvm"
    iso_datastore_id     = "local"
    snippet_datastore_id = "local"

    # No cloud_image_url: reuse the image downloaded by setup.
    cloud_image_name = run.setup.talos_shared_image_file_name

    ip_address      = run.setup.talos_shared_ip_address
    gateway_address = run.setup.gateway_address
    nameservers     = [run.setup.gateway_address]
    domain          = run.setup.search_domain
    search_domain   = run.setup.search_domain

    tags = ["talos", "shared-image", "integration-test"]
  }

  assert {
    condition     = tostring(output.vm_id) == tostring(run.setup.talos_shared_vm_id)
    error_message = "The shared-image Talos VM must be created from the pre-downloaded image."
  }

  assert {
    condition     = output.vm_name == run.setup.talos_shared_vm_name
    error_message = "The shared-image Talos VM output must expose the created VM name."
  }

  assert {
    condition     = output.network_config.ip_address == "${run.setup.talos_shared_ip_address}/24"
    error_message = "The shared-image Talos VM must still get its static IP from cloud-init."
  }
}

run "verify_talos_shared_api" {
  module {
    source = "./tests/verify"
  }

  variables {
    node = trimsuffix(run.create_talos_vm_shared_image.network_config.ip_address, "/24")
  }

  assert {
    condition     = output.talos_api_reachable == "true"
    error_message = "A VM booted from a pre-downloaded image must reach the Talos API on its static IP."
  }
}

###############################################################################
# Fedora + cloud-init                                                         #
###############################################################################

run "create_fedora_vm" {
  variables {
    id       = run.setup.fedora_vm_id
    name     = run.setup.fedora_vm_name
    pve_node = "pve"

    on_boot   = false
    cores     = 2
    memory    = 2048
    disk_size = 25

    datastore_id         = "local-lvm"
    iso_datastore_id     = "local"
    snippet_datastore_id = "local"

    cloud_image_url       = run.setup.fedora_image_url
    cloud_image_file_name = run.setup.fedora_image_file_name
    os_family             = "redhat"

    use_cloud_init_file  = true
    use_user_account     = false
    get_github_keys      = false
    ssh_private_key_path = run.setup.ssh_private_key_path

    user_config = {
      username        = "tftest"
      root_password   = "tftest-root-password"
      user_password   = "tftest-user-password"
      ssh_public_keys = [run.setup.ssh_public_key]
    }

    ip_address      = run.setup.fedora_ip_address
    gateway_address = run.setup.gateway_address
    nameservers     = [run.setup.gateway_address]
    domain          = run.setup.search_domain
    search_domain   = run.setup.search_domain

    tags = ["fedora", "cloud-init", "integration-test"]
  }

  assert {
    condition     = tostring(output.vm_id) == tostring(run.setup.fedora_vm_id)
    error_message = "The Fedora VM output must expose the created VM ID."
  }

  assert {
    condition     = output.vm_name == run.setup.fedora_vm_name
    error_message = "The Fedora VM output must expose the created VM name."
  }

  assert {
    condition     = output.vm_cpu_count == 2 && output.vm_memory == 2048
    error_message = "The Fedora VM outputs must expose the configured compute resources."
  }

  assert {
    condition     = output.network_config.ip_address == "${run.setup.fedora_ip_address}/24"
    error_message = "The Fedora VM output must expose the configured static IP address."
  }

  assert {
    condition     = output.agent == true
    error_message = "The QEMU agent must be enabled for cloud-init based VMs."
  }
}

run "verify_fedora_cloud_init" {
  module {
    source = "./tests/verify-fedora"
  }

  variables {
    host                 = trimsuffix(run.create_fedora_vm.network_config.ip_address, "/24")
    username             = "tftest"
    ssh_private_key_path = run.setup.ssh_private_key_path
    # Fedora's cloud-init prefers the fqdn over the short hostname, and the
    # redhat template renders both from the module's name/domain locals.
    expected_hostname = "${run.setup.fedora_vm_name}.${run.setup.search_domain}"
  }

  assert {
    condition     = output.ssh_reachable == "true"
    error_message = "SSH key authentication must work with the key injected through cloud-init."
  }

  assert {
    condition     = output.cloud_init_done == "true"
    error_message = "cloud-init runcmd must complete and create /tmp/cloud-config.done."
  }

  assert {
    condition     = output.hostname == "${run.setup.fedora_vm_name}.${run.setup.search_domain}"
    error_message = "The guest hostname must match the fqdn rendered by the redhat cloud-init template."
  }

  assert {
    condition     = output.guest_agent_active == "true"
    error_message = "qemu-guest-agent must be installed and active after cloud-init."
  }
}
