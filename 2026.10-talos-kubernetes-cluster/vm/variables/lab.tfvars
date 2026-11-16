k8s_nodes = {
  "controlplane-01.mydomain.io" = {
    ip        = "192.168.90.21"
    role      = "controlplane"
    vm_id     = 80001
    host_node = "pve"
    cores     = 4
    memory    = 8192
    disk_size = 50
    tags      = ["kubernetes", "talos", "controlplane", "lab"]
  }
  "controlplane-02.mydomain.io" = {
    ip        = "192.168.90.22"
    role      = "controlplane"
    vm_id     = 80002
    host_node = "pve"
    cores     = 4
    memory    = 8192
    disk_size = 50
    tags      = ["kubernetes", "talos", "controlplane", "lab"]
  }
  "controlplane-03.mydomain.io" = {
    ip        = "192.168.90.23"
    role      = "controlplane"
    vm_id     = 80003
    host_node = "pve"
    cores     = 4
    memory    = 8192
    disk_size = 50
    tags      = ["kubernetes", "talos", "controlplane", "lab"]
  }

  "worker-01.mydomain.io" = {
    ip        = "192.168.90.31"
    role      = "worker"
    vm_id     = 80031
    host_node = "pve"
    cores     = 4
    memory    = 8192
    disk_size = 50
    tags      = ["kubernetes", "talos", "worker", "lab"]
  }
  "worker-02.mydomain.io" = {
    ip        = "192.168.90.32"
    role      = "worker"
    vm_id     = 80032
    host_node = "pve"
    cores     = 4
    memory    = 8192
    disk_size = 50
    tags      = ["kubernetes", "talos", "worker", "lab"]
  }
  "worker-03.mydomain.io" = {
    ip        = "192.168.90.33"
    role      = "worker"
    vm_id     = 80033
    host_node = "pve"
    cores     = 4
    memory    = 8192
    disk_size = 50
    tags      = ["kubernetes", "talos", "worker", "lab"]
  }
  "worker-04.mydomain.io" = {
    ip        = "192.168.90.34"
    role      = "worker"
    vm_id     = 80034
    host_node = "pve"
    cores     = 4
    memory    = 8192
    disk_size = 50
    tags      = ["kubernetes", "talos", "worker", "lab"]
  }
  "worker-05.mydomain.io" = {
    ip        = "192.168.90.35"
    role      = "worker"
    vm_id     = 80035
    host_node = "pve"
    cores     = 4
    memory    = 8192
    disk_size = 50
    tags      = ["kubernetes", "talos", "worker", "lab"]
  }
}
