# 2026.10 — Cluster Kubernetes Talos

https://www.youtube.com/watch?v=oxcGDRVIOsk

Workshop : déployer un cluster Kubernetes sous Talos Linux sur Proxmox VE from scratch, provisionnement des VMs, bootstrap du cluster et manifests inline (CNI/Flux),
réparti sur deux root modules Terraform indépendants.

| Couche    | Version   |
| --------- | --------- |
| Talos     | `v1.14.5` |
| Kubernetes | `v1.37.0` |
| Plateforme | `nocloud` (images disque Factory bootées directement par Proxmox) |

## Structure

```text
.
├── vm/          # Root module 1 — VMs Talos sur Proxmox (nœuds k8s)
├── cluster/     # Root module 2 — bootstrap du cluster Talos
└── modules/     # Copies locales des modules upstream, pour lecture/référence
    ├── proxmox-vm/
    └── talos-cluster/
```

`vm/` et `cluster/` ne se partagent rien au moment du plan : ils gardent des
fichiers d'état distincts (`lab.nodes.tfstate`, `lab.talos-bootstrap.tfstate`)
et s'appliquent dans l'ordre — impossible de bootstrapper un cluster dans des
machines qui n'existent pas encore.

## Topologie du cluster (`lab`)

| Nœud                 | IP             | Rôle          |
| -------------------- | -------------- | ------------- |
| controlplane-01..03  | 192.168.90.21–23 | controlplane |
| worker-01..05        | 192.168.90.31–35 | worker       |
| LB TCP               | 192.168.90.80  | front `:6443` |

- Endpoint du cluster : `https://192.168.90.80:6443` (le LB gagne ; fallback
  sur la première IP controlplane si `load_balancer_ip` est non défini)
- Les SAN du certificat kube-apiserver incluent `k8s-cluster.mydomain.io` plus
  l'IP du LB
- Les noms de nœuds utilisent `mydomain.io` ; passerelle `192.168.90.1`

## Comment tout s'emboîte

1. **`vm/`** construit un schematic Talos Factory (`qemu-guest-agent`,
   `iscsi-tools`, `util-linux-tools` + certificats secureboot well-known),
   télécharge l'image `nocloud-amd64` correspondante sur chaque hôte Proxmox
   et crée une VM par entrée `k8s_nodes` — sans ISO d'installation, sans
   cloud-init.
2. **`cluster/`** rend les machine configs par nœud depuis
   `templates/talos/` (patch commun + patches controlplane/worker), bootstrape
   via la première IP controlplane, et injecte chaque chart de
   `templates/charts.packages.json` ainsi que les manifests
   `vault-auth-reviewer`, `namespaces` et `cilium.loadbalancing` en inline
   manifests du control-plane. Les values Cilium + Flux operator vivent sous
   `templates/k8s/helm/`.
3. Régénérer les inline manifests après édition des values :
   `just env=lab gen-inline-manifests` (voir `cluster/.justfile`).

## Outputs (`cluster/`)

| Output                  | Contenu                                          |
| ----------------------- | ------------------------------------------------ |
| `talos_client_config`   | `talosconfig` (sensible)                         |
| `k8s_client_config`     | `kubeconfig` (sensible)                          |
| `k8s_endpoint`          | endpoint de l'API                                |
| `talos_installer_image` | référence installer alignée sur la plateforme    |
| `machine_secrets`       | secrets machine pour la gestion future           |
| `machine_configurations`| machine config patchée par nœud (sensible)       |

## Exécution

```bash
# 1 — VMs Proxmox
cd vm
terraform init -backend-config=variables/backend.tfvars
terraform plan  -var-file=variables/backend.tfvars -var-file=variables/common.tfvars -var-file=variables/lab.tfvars
terraform apply ...

# 2 — Bootstrap du cluster
cd ../cluster
terraform init -backend-config=variables/backend.tfvars
terraform plan  -var-file=variables/backend.tfvars -var-file=variables/common.tfvars -var-file=variables/lab.tfvars
terraform apply ...
```

L'authentification des providers se fait via l'environnement
(`PROXMOX_VE_*` / credentials S3 — les valeurs actuelles de
`variables/backend.tfvars` sont des placeholders `replaceme`).

### Backend

Le backend S3 est **optionnel mais recommandé** : sans lui, chaque module
conserve un `terraform.tfstate` local. Le state distant apporte un état
verrouillé, partagé, et récupérable en cas de perte de la machine.
`vm/variables/backend.tfvars` est livré avec la clé d'état commentée — à
définir avant de l'activer.

## Remarques

- Les modules sont référencés par des **chemins locaux** vers `~/Workstation/perso/tf-modules` (`cluster` → `src/talos-cluster`, `vm` →
  chemin cassé pour l'instant, voir plus bas). Revenir aux refs git épinglées
  (`proxmox-vm-v1.0.1`, `talos-cluster-v1.0.2`) pour l'exécuter sur une autre
  machine.
- `modules/` est un instantané en lecture seule des modules upstream — ne pas
  lancer de plan depuis ce dossier.
- `cluster/variables/prod.tfvars` provient du stack source ; ce workshop
  cible uniquement `lab`.
