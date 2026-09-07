# DOCKER : Vers l'Orchestration Multi-Nœuds (Swarm & Kubernetes) {-}

### Le Besoin d'Orchestration : Sortir du Serveur Unique

Sur un serveur unique, si la machine tombe en panne, tous vos conteneurs sont indisponibles.

> L'**Orchestration** regroupe un ensemble de machines physiques ou virtuelles (*Cluster*) pour former un **supercalculateur unifié**, capable de :
> - Répartir automatiquement les conteneurs sur les nœuds disponibles (*Scheduling*).
> - Remplacer instantanément un conteneur ou un nœud tombé en panne (*Self-Healing*).
> - Mettre à l'échelle dynamiquement (*Scaling horizontal*).
> - Mettre à jour les applications sans interruption de service (*Rolling Updates*).

### Architecture Interne de Docker Swarm

Docker Swarm est le moteur d'orchestration natif intégré directement dans Docker Engine :

```{.center}
                    GROUPE DE CONSENSUS RAFT (MANAGERS)
┌────────────────────────────────────────────────────────────────────────┐
│ Manager Leader ◄─────────► Manager 2 ◄─────────► Manager 3             │
│ (API + Scheduler + Store Raft chiffré + Autorité de Certification TLS) │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Communication mTLS (port 2377)
             ┌──────────────────────┼──────────────────────┐
             ▼                      ▼                      ▼
┌──────────────────────┐ ┌──────────────────────┐ ┌──────────────────────┐
│ WORKER NODE 1        │ │ WORKER NODE 2        │ │ WORKER NODE 3        │
│ [ Task: App replica1]│ │ [ Task: App replica2]│ │ [ Task: App replica3]│
└──────────────────────┘ └──────────────────────┘ └──────────────────────┘
```

- **Tasks** : L'unité atomique d'exécution (1 tâche = 1 conteneur).
- **Services** : Définition de l'état désiré (`replicas: 3`, image, ports, contraintes de placement).

### Le Réseau Overlay & le Routing Mesh

Swarm intègre un mécanisme de distribution du trafic réseau sur l'ensemble du cluster :

```{.center}
                            REQUÊTE HTTP : PORT 80
                                       │
                                       ▼
┌────────────────────────────────────────────────────────────────────────┐
│                    SWARM ROUTING MESH (IPVS + VXLAN)                   │
│  Le port publié 80 est ouvert sur TOUS les nœuds du cluster,           │
│  même ceux qui n'exécutent AUCUN conteneur de l'application !          │
└──────────────────┬───────────────────┬───────────────────┬─────────────┘
                   │                   │                   │
                   ▼                   ▼                   ▼
             [ Nœud 1 : App ]    [ Nœud 2 : App ]    [ Nœud 3 : Vide ]
                                                           │ (Redirige vers
                                                           └── Nœud 1 ou 2)
```

### Déploiement de Stacks Déclaratives

Swarm réutilise la syntaxe de `compose.yaml` enrichie de la section `deploy` :

```yaml
# stack.yaml
services:
  web:
    image: my-app:1.2.0
    ports:
      - "80:80"
    deploy:
      replicas: 5
      update_config:
        parallelism: 2
        delay: 10s
        failure_action: rollback
      restart_policy:
        condition: on-failure
      placement:
        constraints:
          - node.role == worker
```

```bash
# 1. Initialiser le cluster Swarm sur le premier manager
docker swarm init

# 2. Déployer toute la pile applicative
docker stack deploy -c stack.yaml production-app

# 3. Suivre le déploiement des tâches
docker stack ps production-app
```

### Gestion des Secrets dans Swarm

Swarm intègre un coffre-fort sécurisé :
- Les secrets sont stockés chiffrés au repos dans le datastore Raft des managers.
- Transmis aux workers exclusivement via TLS mutuel.
- Montés **uniquement en mémoire vive (tmpfs)** dans `/run/secrets/<nom_secret>` des conteneurs autorisés.

```bash
# Création d'un secret Swarm
echo "super-password-123" | docker secret create db_root_pwd -
```

### Quand Passer de Docker Swarm à Kubernetes ?

| Fonctionnalité | Docker Swarm | Kubernetes (K8s) |
| :--- | :--- | :--- |
| **Complexité d'installation** | Immédiate (`docker swarm init`) | Moyenne à élevée (Cloud managé EKS/GKE/AKS recommandé) |
| **Écosystème & Communauté** | Réduit / Stable | Standard mondial de l'industrie (CNCF) |
| **Autoscaling (HPA / VPA)** | Manuel | Automatique selon CPU, RAM ou métriques métier |
| **Stockage & CSI** | Local / NFS basique | Pilotes CSI avancés, snapshots, PVC dynamiques |
| **GitOps & Ingress Moderne** | Limité | ArgoCD, Flux, Traefik, Cilium eBPF, Gateway API |
| **Gestion Fine des Droits** | Basique | RBAC granulaire, OIDC, Pod Security Standards |

### Mini-Défi : Résilience d'un Cluster Swarm

**Question** : Que se passe-t-il si un nœud Worker hébergeant 2 répliques de conteneurs s'éteint brutalement dans un cluster Swarm ?

- **A.** Tout le cluster Swarm s'arrête instantanément.
- **B.** Les conteneurs sont définitivement perdus et ne redémarrent jamais.
- **C.** Les managers détectent la perte du nœud (Heartbeat) et replanifient immédiatement les 2 conteneurs sur les autres nœuds sains du cluster.
- **D.** Une simple notification par email est envoyée sans action corrective.

### Mini-Défi : Résilience d'un Cluster Swarm

**Question** : Que se passe-t-il si un nœud Worker hébergeant 2 répliques de conteneurs s'éteint brutalement dans un cluster Swarm ?

- **A.** Tout le cluster Swarm s'arrête instantanément.
- **B.** Les conteneurs sont définitivement perdus et ne redémarrent jamais.
- **C.** Les managers détectent la perte du nœud (Heartbeat) et replanifient immédiatement les 2 conteneurs sur les autres nœuds sains du cluster.
- **D.** Une simple notification par email est envoyée sans action corrective.

```{.center}
┌─────────────────────────────────────────────────────────────┐
│                        RÉPONSE : C                          │
│  Le groupe de consensus Raft (Managers) détecte la rupture  │
│  du Heartbeat et ordonne au scheduler d'instancier 2        │
│  nouvelles tâches pour restaurer l'état désiré (Replicas).  │
└─────────────────────────────────────────────────────────────┘
```

