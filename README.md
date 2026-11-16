# Workshops

Dépôt de workshops — supports pratiques et pas-à-pas pour expérimenter de
nouveaux outils, architectures ou flux avant de les industrialiser dans le
homelab (craftarc).

Chaque workshop vit dans son propre dossier, nommé
`<année.mois>-<sujet>` :

```text
.
└── 2026.10-talos-kubernetes-cluster/
```

## Workshops

| Workshop                      | Sujet                                                                 |
| ----------------------------- | -------------------------------------------------------------------- |
| [2026.10-talos-kubernetes-cluster](./2026.10-talos-kubernetes-cluster/) | Déployer un cluster Kubernetes Talos sur Proxmox VE de zéro — provisionnement des VMs, bootstrap du cluster, CNI/Flux |

## Conventions

- Un workshop = un dossier autonome : chaque dossier embarque son propre
  README détaillé et reste exécutable indépendamment du reste du dépôt.
- Le contenu est expérimental : les chemins vers les modules locaux
  (`tf-modules`) et les placeholders de secrets (`replaceme`) sont assumés —
  repasser aux refs git épinglées et aux vrais backends si un workshop est
  repris en production.
