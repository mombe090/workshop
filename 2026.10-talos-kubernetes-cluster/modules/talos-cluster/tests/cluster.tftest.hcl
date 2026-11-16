variables {
  cluster_name       = "tftest-lab-cluster"
  cluster_endpoint   = "https://192.0.2.10:6443"
  talos_version      = "v1.14.0"
  kubernetes_version = "v1.37.0"
  bootstrap_node     = "192.0.2.10"

  nodes = {
    cp-01 = {
      ip   = "192.0.2.10"
      role = "controlplane"
    }
    cp-02 = {
      ip   = "192.0.2.11"
      role = "controlplane"
    }
    worker-01 = {
      ip   = "192.0.2.20"
      role = "worker"
    }
  }
}

run "plan_cluster" {
  command = plan

  assert {
    condition     = length(talos_machine.this) == 3
    error_message = "One talos_machine must be planned for every node."
  }

  assert {
    condition     = talos_machine.this["worker-01"].ignore_kubernetes_upgrade_drift
    error_message = "talos_cluster must exclusively own Kubernetes component upgrades."
  }

  assert {
    condition     = join(",", talos_cluster.this.control_plane_nodes) == "192.0.2.10,192.0.2.11"
    error_message = "talos_cluster must receive every control-plane IP in deterministic order."
  }

  assert {
    condition     = talos_cluster.this.node == "192.0.2.10" && talos_cluster_kubeconfig.this.node == "192.0.2.10"
    error_message = "Bootstrap and kubeconfig retrieval must use the selected control-plane node."
  }
}

run "reject_worker_bootstrap" {
  command = plan

  variables {
    bootstrap_node = "192.0.2.20"
  }

  expect_failures = [var.bootstrap_node]
}

run "reject_duplicate_node_ips" {
  command = plan

  variables {
    nodes = {
      cp-01 = {
        ip   = "192.0.2.10"
        role = "controlplane"
      }
      worker-01 = {
        ip   = "192.0.2.10"
        role = "worker"
      }
    }
  }

  expect_failures = [var.nodes]
}
