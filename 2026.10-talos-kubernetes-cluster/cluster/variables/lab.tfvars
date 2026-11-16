environment = "lab"

gateway_ip  = "192.168.90.1"
nameservers = ["192.168.10.111", "192.168.90.113"]

load_balancer_ip = "192.168.90.80"

k8s_nodes = {
  "controlplane-01.mydomain.io" = {
    ip           = "192.168.90.21"
    role         = "controlplane"
    install_disk = "/dev/vda"
  }
  "controlplane-02.mydomain.io" = {
    ip           = "192.168.90.22"
    role         = "controlplane"
    install_disk = "/dev/vda"
  }
  "controlplane-03.mydomain.io" = {
    ip           = "192.168.90.23"
    role         = "controlplane"
    install_disk = "/dev/vda"
  }


  "worker-01.mydomain.io" = {
    ip           = "192.168.90.31"
    role         = "worker"
    install_disk = "/dev/vda"
  }

  "worker-02.mydomain.io" = {
    ip           = "192.168.90.32"
    role         = "worker"
    install_disk = "/dev/vda"
  }

  "worker-03.mydomain.io" = {
    ip           = "192.168.90.33"
    role         = "worker"
    install_disk = "/dev/vda"
  }

  "worker-04.mydomain.io" = {
    ip           = "192.168.90.34"
    role         = "worker"
    install_disk = "/dev/vda"
  }

  "worker-05.mydomain.io" = {
    ip           = "192.168.90.35"
    role         = "worker"
    install_disk = "/dev/vda"
  }
}
