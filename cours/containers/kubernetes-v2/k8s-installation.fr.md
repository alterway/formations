# KUBERNETES : Stratégies d'Installation & Typologies {-}

### Quelle Installation pour Quel Besoin ?

| Environnement | Outils Recommandés | Cas d'Usage Principal |
| :--- | :--- | :--- |
| **Dev Local & CI/CD** | `KinD`, `k3d` / `k3s`, `Minikube` | Tester des manifests, reproduire un cluster multi-nœuds en 30s |
| **On-Premise / Bare Metal** | `kubeadm`, `kubespray` (Ansible), `Cluster API` | Contrôle total du matériel, isolation souveraine |
| **Cloud Managé (Public Cloud)** | `GKE`, `EKS`, `AKS`, `Kapsule` | Délégation du Control Plane, autoscaling nœuds cloud natif |

### Le Dev Local Moderne : KinD & K3d

```bash
# Cluster multi-nœuds en local en 1 commande avec KinD
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
EOF
```

- **KinD (Kubernetes-in-Docker)** : Chaque nœud K8s est un conteneur Docker. Idéal pour simuler des pannes de nœuds sans latence !
- **k3d / K3s** : K8s allégé (remplace etcd par SQLite si 1 nœud), démarrage en 5 secondes.

### L'Installation Standard : `kubeadm`

`kubeadm` est l'outil officiel standard pour initialiser un cluster de production :

```{.center}
[ Étape 1 : Control Plane ]
  $ sudo kubeadm init --pod-network-cidr=10.244.0.0/16
         │
         ▼ (Génère certificats TLS, etcd, apiserver, et le token de join)
[ Étape 2 : Plugin Réseau (CNI) ]
  $ kubectl apply -f https://docs.cilium.io/...
         │
         ▼ (Les nœuds passent de NotReady à Ready)
[ Étape 3 : Raccordement des Workers ]
  $ sudo kubeadm join 192.168.1.10:6443 --token <token> --discovery-token-ca-cert-hash sha256:...
```

### Modèle de Responsabilité Partagée (Managed Cloud)

```{.center}
┌─────────────────────────────────────────────────────────────┐
│ Fournisseur Cloud (GCP/AWS/Azure/Scaleway/OVH...)           │
│  ► etcd, kube-apiserver, scheduler, controller-manager      │
│  ► Sauvegardes etcd, patchs de sécurité, haute dispo        │
├─────────────────────────────────────────────────────────────┤
│ Votre Responsabilité (DevOps / SRE)                         │
│  ► Gestion des versions de Worker Nodes (Node Pools)        │
│  ► Sécurité réseau, RBAC, ingress, dimensionnement (HPA)    │
│  ► Vos manifests applicatifs et vos données                 │
└─────────────────────────────────────────────────────────────┘
```

### Audit & Conformité : Sécuriser Dès l'Installation

Avant de mettre un cluster en production, auditez sa conformité :

- **`kube-bench`** : Vérifie la stricte conformité avec le **CIS Kubernetes Benchmark** (droits des fichiers de config, arguments TLS).
- **`popeye`** : Scanner assainisseur qui détecte les ressources orphelines, allocations manquantes et erreurs de config.
- **`sonobuoy`** : Outil officiel de validation de conformité CNCF.

```bash
# Scanner son cluster avec Popeye en 1 commande :
popeye
```


### Mini-Défi : Choix d'Architecture (Réponses)

**Contexte** : Votre entreprise veut monter une chaîne CI/CD GitHub Actions pour tester le déploiement d'opérateurs K8s multi-nœuds à chaque Pull Request.

**Question** : Quelle solution privilégiez-vous ?
1. Un cluster EKS dédié allumé 24/7.
2. Un cluster local `KinD` instancié dynamiquement dans le runner de la CI.
3. Une VM avec `Minikube`.


### Mini-Défi : Choix d'Architecture (Réponses)

**Contexte** : Votre entreprise veut monter une chaîne CI/CD GitHub Actions pour tester le déploiement d'opérateurs K8s multi-nœuds à chaque Pull Request.

**Question** : Quelle solution privilégiez-vous ?
1. Un cluster EKS dédié allumé 24/7.
2. Un cluster local `KinD` instancié dynamiquement dans le runner de la CI.
3. Une VM avec `Minikube`.


**Réponse** : **Option 2 (KinD)** ! Démarrage en ~20s, destruction automatique à la fin du job, coût quasi nul et isolation parfaite.

