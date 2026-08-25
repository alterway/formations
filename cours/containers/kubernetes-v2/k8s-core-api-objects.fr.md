# KUBERNETES : Les Objets Cœurs & Workloads {-}

### La Hiérarchie des Objets Kubernetes

```
 ┌─────────────────────────────────────────────────────────────┐
 │                      NAMESPACE                              │
 │                                                             │
 │   ┌─────────────────────────────────────────────────────┐   │
 │   │                   DEPLOYMENT                        │   │
 │   │    (Gère les Rolling Updates & l'historique)        │   │
 │   │                        │                            │   │
 │   │                        ▼                            │   │
 │   │                   REPLICASET                        │   │
 │   │        (Maintient le nombre exact de Pods)          │   │
 │   │                        │                            │   │
 │   │                        ▼                            │   │
 │   │                      PODS                           │   │
 │   │         [ App Container | Native Sidecar ]          │   │
 │   └─────────────────────────────────────────────────────┘   │
 └─────────────────────────────────────────────────────────────┘
```

### 1. Le Pod : L'Atome Indivisible

![](images/kubernetes/kubernetes-pod.png){height="180px"}

- **Définition** : La plus petite unité déployable dans Kubernetes.
- **Ce que partagent les conteneurs d'un même Pod** :
  - **Réseau** : Même adresse IP, communication sur `localhost`, mêmes ports.
  - **Stockage** : Volumes partagés montés dans leurs systèmes de fichiers.
  - **IPC & UTC** : Mémoire partagée et horloge commune.

### Les Sidecars Natifs (K8s 1.28+)

Fini les bricolages pour attendre qu'un proxy démarre avant votre application principale :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secured-webapp
spec:
  initContainers:
  - name: vault-agent-sidecar
    image: hashicorp/vault:latest
    restartPolicy: Always   # <── Transforme l'initContainer en Sidecar natif !
  containers:
  - name: app
    image: my-app:2.0
```

- Le sidecar démarre **avant** l'application principale et s'éteint **après** elle !

### 2. Labels vs Annotations : Ne Les Confondez Plus !

```
              LABELS                             ANNOTATIONS
  Utilisés par Kubernetes pour sélectionner    Utilisés par des outils tiers
        (Sélecteurs, Services, RBAC)           (Monitoring, CI/CD, Git commit)
                │                                       │
                ▼                                       ▼
  - app: bookstore                             - git-commit: 7f8a92b
  - env: production                            - prometheus.io/scrape: "true"
  - tier: backend                              - ingress.class: nginx
```

> **Règle d'or** : Si Kubernetes doit filtrer ou router dessus $\rightarrow$ **Label**. Si c'est informatif $\rightarrow$ **Annotation**.

### 3. Le Deployment & ReplicaSet : Piloter les Versions

Le Deployment orchestre des **ReplicaSets** pour garantir des mises à jour sans interruption :

```
[ Deployment v1 ] ──► [ ReplicaSet v1 (3 Pods) ]  ◄── Traffic 100%
         │
    (Mise à jour d'image vers v2 : RollingUpdate)
         │
         ├──► [ ReplicaSet v1 (1 Pod) ]          ◄── Traffic 33%
         └──► [ ReplicaSet v2 (2 Pods) ]          ◄── Traffic 67%
```

![](images/kubernetes/rollingupdate.png){height="220px"}

### Contrôler le Rolling Update

```yaml
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # Max 1 pod en plus pendant le déploiement (total 6)
      maxUnavailable: 0  # 0 interruption tolérée : aucun pod détruit avant qu'un nouveau soit Ready
```

```bash
# Surveiller en direct le déploiement
kubectl rollout status deployment/web-app

# Revenir en arrière en cas de bug en 1 seconde !
kubectl rollout undo deployment/web-app
```

### 4. StatefulSet : Pour les Données & l'Ordre Strict

Quand vos applications ne sont pas jetables (bases de données, Kafka, ElasticSearch) :

```
[ StatefulSet: redis ]
   ├── redis-0  ──► Lié au PVC data-redis-0 (Disque SSD 1)
   ├── redis-1  ──► Lié au PVC data-redis-1 (Disque SSD 2)
   └── redis-2  ──► Lié au PVC data-redis-2 (Disque SSD 3)
```

- **Nommage prédictible et stable** (`nom-0`, `nom-1`...).
- **Création ordonnée** : Le pod 1 démarre uniquement quand le pod 0 est `Ready`.
- **Persistance garantie** : Si un pod meurt, son remplaçant récupère exactement le même disque !

### 5. DaemonSet, Job & CronJob

| Objet | Rôle Principal | Cas d'Usage Typique |
| :--- | :--- | :--- |
| **DaemonSet** | Exécute exactement **1 copie du Pod sur chaque nœud** | Collecteur de logs (Fluentd), agent de métriques (Prometheus node-exporter), CNI |
| **Job** | Exécute une tâche jusqu'à son terme (succès) puis s'arrête | Migration de schéma SQL, calcul de rapport ponctuel |
| **CronJob** | Planifie des Jobs selon une expression temporelle cron | Sauvegarde nocturne `0 2 * * *`, nettoyage de logs |

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: db-backup
spec:
  schedule: "0 3 * * *"  # Tous les jours à 3h du matin
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: pg-dump
            image: postgres:16-alpine
          restartPolicy: OnFailure
```

### Mini-Défi : Le « Piège du Sélecteur »

**Code Review** : Pourquoi le Service ci-dessous ne reçoit aucun trafic bien que les 3 Pods du Deployment soient `Running` ?

```yaml
# Deployment
spec:
  template:
    metadata:
      labels:
        app: backend-api
        tier: core
---
# Service
spec:
  selector:
    app: backend-api
    tier: api
```

*(Réponse : Le sélecteur du Service exige `tier: api`, alors que les Pods ont `tier: core`. Les labels doivent correspondre exactement !).*
