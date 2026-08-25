# KUBERNETES : Architecture & Mécanique Interne {-}

### Vue d'Ensemble : Deux Mondes Complémentaires

```
 ┌─────────────────────────────────────────────────────────────┐
 │                CONTROL PLANE (Cerveau)                      │
 │   [ etcd ] ◄──► [ kube-apiserver ] ◄──► [ Controllers ]     │
 │                        ▲                                    │
 │                        │  (Reconcile loop & Scheduler)      │
 └────────────────────────┼────────────────────────────────────┘
                          │ HTTPS / TLS (Port 6443)
 ┌────────────────────────┼────────────────────────────────────┐
 │                        ▼                                    │
 │   WORKER NODE 1                 WORKER NODE 2               │
 │   [ kubelet ] ──► [ CRI ]       [ kubelet ] ──► [ CRI ]     │
 │   [ kube-proxy / eBPF ]         [ kube-proxy / eBPF ]       │
 │   [ Pods / Containers ]         [ Pods / Containers ]       │
 └─────────────────────────────────────────────────────────────┘
```

- **Control Plane (Master)** : Prend les décisions globales, stocke l'état, détecte et réconcilie les écarts.
- **Worker Nodes** : Exécutent vos conteneurs applicatifs et gèrent le trafic réseau local.

![](images/kubernetes/control-plane.webp){height="220px"}

### 1. `etcd` : Le Cœur Persistant

![](images/kubernetes/etcd.svg){height="140px"}

- **Nature** : Base clé-valeur distribuée, ultra-rapide et transactionnelle.
- **Algorithme de consensus RAFT** : Nécessite un quorum strict : $\lfloor N/2 \rfloor + 1$ nœuds (clusters de 3 ou 5 nœuds).
- **Règle absolue** : Seul le `kube-apiserver` dialogue avec `etcd`. Aucun worker ni utilisateur n'y accède directement.
- **En production** : Exige des disques SSD/NVMe à très faible latence (fsync critique).

### 2. `kube-apiserver` : L'Unique Porte d'Entrée

Toute action (`kubectl`, CI/CD, Kubelet) passe par un pipeline strict en 4 étapes :

```
Requête HTTP ──► [1. Authentication] ──► [2. Authorization (RBAC)]
                      │
                      ▼
                 [3. Mutation & Validation (Admission Webhooks)]
                      │
                      ▼
                 [4. Sauvegarde dans etcd]
```

- **Stateless** : Horizontalement scalable derrière un Load Balancer.
- Émet des flux d'événements (`watch`) vers tous les autres contrôleurs.

![](images/kubernetes/kube-api-server-ezgif.com-crop.gif){height="180px"}

### 3. `kube-controller-manager` : La Boucle de Réconciliation

La promesse fondamentale de Kubernetes : **Déclaratif vs Réel**.

```
    ┌───────────────────────────────────────────────┐
    │          LA BOUCLE INFINIE DE CONTRÔLE        │
    │                                               │
    │      1. Observer l'état réel actuel           │
    │      2. Comparer avec l'état désiré (YAML)    │
    │      3. Agir pour résorber l'écart (Reconcile)│
    └───────────────────────────────────────────────┘
```

- Regroupe des dizaines de contrôleurs : *NodeController, ReplicaSetController, EndpointsController, ServiceAccountController...*

![](images/kubernetes/control-loop.svg){height="190px"}

### 4. `kube-scheduler` : L'Aiguilleur Intelligent

Comment un Pod trouve-t-il son Node d'hébergement ?

```
[ Nouveau Pod non assigné (nodeName="") ]
               │
               ▼
      1. Filtrage (Predicates / Filtering)
      (Élimine les nœuds sans CPU/RAM, taints incompatibles...)
               │
               ▼
      2. Notation (Priorities / Scoring)
      (Classe les nœuds restants selon affinité, étalement des charges...)
               │
               ▼
[ Assignation au nœud avec le meilleur score ]
```

![](images/kubernetes/kubescheduler.png){height="190px"}

### Les Composants du Worker Node

![](images/kubernetes/Kubernetes-Architecture-Diagram-Explained.png){height="230px"}

1. **`kubelet`** : L'agent de bord du nœud. Reçoit les ordres de l'APIServer, pilote le runtime conteneur et remonte la santé du nœud.
2. **`CRI (Container Runtime Interface)`** : Le moteur bas niveau (*containerd*, *CRI-O*) qui instancie les namespaces Linux et cgroups.
3. **`kube-proxy` / `eBPF`** : Configure le routage réseau local et le load balancing entre Pods.

### Les Modes Réseau : Du Legacy à l'eBPF

- **Userspace (historique)** : Lent, passage constant entre kernel et user space.
- **iptables** : Standard historique par règles de filtrage séquentielles (sature à partir de 10 000 services).
- **IPVS (IP Virtual Server)** : Tables de hachage Linux, rapide et taillé pour la volumétrie.
- **eBPF (ex. Cilium)** : Remplacement moderne de `kube-proxy`, routage directement dans le noyau sans surcoût iptables !

![](images/kubernetes/services-iptables-overview.svg){height="200px"}

### Le Modèle Réseau Fondamental

Kubernetes impose **3 règles absolues** à tous les plugins réseau (CNI) :

1. Tous les Pods peuvent communiquer entre eux **sans NAT**.
2. Tous les Nodes peuvent communiquer avec tous les Pods **sans NAT**.
3. L'adresse IP qu'un Pod voit pour lui-même est **exactement la même** que celle vue par les autres.

*Exemples de CNI majeurs* : **Cilium** (eBPF & haute performance), **Calico** (politiques de sécurité BGP/IP-in-IP), **Flannel** (overlay simple).

### Mini-Défi SRE : Autopsie de Pannes

**Scénario 1** : Si le `kube-apiserver` devient inaccessible pendant 10 minutes, que deviennent les Pods applicatifs en cours d'exécution ?


**Scénario 2** : Si le `kube-scheduler` crashe, que se passe-t-il lors d'un `kubectl apply` d'un nouveau Deployment ?


### Mini-Défi SRE : Autopsie de Pannes (Réponses)

**Scénario 1** : Si le `kube-apiserver` devient inaccessible pendant 10 minutes, que deviennent les Pods applicatifs en cours d'exécution ?

**Réponse** : Ils continuent de tourner normalement ! Seules les opérations de modification et le redémarrage en cas de crash sont gelés.

**Scénario 2** : Si le `kube-scheduler` crashe, que se passe-t-il lors d'un `kubectl apply` d'un nouveau Deployment ?

**Réponse** : Le Deployment et les Pods sont créés dans etcd, mais les Pods restent bloqués en état `Pending`.

