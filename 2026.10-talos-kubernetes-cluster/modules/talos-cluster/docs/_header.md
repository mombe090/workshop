# Talos Cluster Bootstrap Module

Bootstraps a Talos Kubernetes cluster on existing nodes. The module does not create Proxmox VMs, download boot images, or deploy platform add-ons.

## Scope

- Applies initial machine configuration with one `talos_machine` per node.
- Bootstraps etcd with exactly one `talos_cluster`.
- Keeps Kubernetes version management with `talos_cluster`.
- Outputs kubeconfig and talosconfig for client access.

Initial hostname, network, and installation-disk configuration can be supplied through each node's `config_patches`. Patches are passed only to `talos_machine_configuration`; they are not duplicated in `talos_machine`.

The module intentionally omits `talos_machine.image`, so it does not manage Talos OS upgrades. `talos_version` pins the machine configuration contract and must not be used as the installed OS version.
