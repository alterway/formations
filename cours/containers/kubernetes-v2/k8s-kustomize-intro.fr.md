# KUBERNETES : Configuration Déclarative avec Kustomize {-}

### Le Concept : Personnaliser Sans Moteur de Templates

```{.center}
                  [ BASE (Manifests Communs) ]
                  (Deployment, Service, Config)
                                │
               ┌────────────────┴────────────────┐
               ▼                                 ▼
    [ OVERLAY : STAGING ]              [ OVERLAY : PRODUCTION ]
  - 1 Réplica                        - 10 Réplicas
  - Image : tag staging              - Image : tag v2.1.0 (immuable)
  - Petites ressources CPU/RAM       - Grosses ressources + HPA
```

- **Principe fondamental** : Pas de syntaxe `{{ .Values }}` complexe. On part de manifests YAML purs et standards, et on applique des correctifs (**patches**) chirurgicaux par environnement.
- Intégré **nativement dans `kubectl`** depuis la version 1.14 (`kubectl apply -k`).

### Structure d'un Répertoire Kustomize

```
k8s/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── overlays/
    ├── dev/
    │   ├── kustomization.yaml
    │   └── replica_patch.yaml
    └── production/
        ├── kustomization.yaml
        └── resources_patch.yaml
```

### Le Fichier `kustomization.yaml` en Pratique

```yaml
# overlays/production/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: production
namePrefix: prod-

resources:
  - ../../base

images:
  - name: bookstore-api
    newTag: v2.1.4

patches:
  - path: resources_patch.yaml
    target:
      kind: Deployment
      name: bookstore-api
```

### Générateurs Automatiques : Adieu les Bugs de Cache

```yaml
configMapGenerator:
  - name: app-config
    files:
      - config.properties
```

- **Fonctionnalité magique** : Kustomize calcule un hash SHA du contenu du fichier (ex: 
`app-config-7b2m8f4k9g`).

- Lorsque vous modifiez `config.properties`, le nom du ConfigMap change, ce qui force Kubernetes à déclencher **automatiquement un Rolling Update propre** de tous les Pods sans manipulation manuelle !

### Helm vs Kustomize : Le Tableau Décisionnel

| Critère | Helm | Kustomize |
| :--- | :--- | :--- |
| **Philosophie** | Templating Go paramétré | Héritage & Patches déclaratifs |
| **Dépendance externe** | Binaire `helm` requis | Intégré dans `kubectl` |
| **Gestion des Secrets / CM** | Manuelle | Hash automatique (Rolling update forcé) |
| **Cas d'usage Idéal** | Applications tierces CNCF (Ingress, Cert-Manager) | Vos propres microservices internes en GitOps |

### Mini-Défi : Déploiement Kustomize

```bash
# Quelle commande permet d'inspecter le rendu final de l'overlay production sans rien appliquer ?
kubectl kustomize overlays/production/

# Quelle commande permet d'appliquer directement l'overlay en production ?
kubectl apply -k overlays/production/
```

