# KUBERNETES : Sécurité, RBAC & Isolation Réseau {-}

### Le Modèle des 4C de la Sécurité Cloud Native

```
                                ┌───────────────────────────────────────────┐
                                │                  CLOUD                    │
                                │   ┌───────────────────────────────────┐   │
                                │   │              CLUSTER              │   │
                                │   │   ┌───────────────────────────┐   │   │
                                │   │   │         CONTAINER         │   │   │
                                │   │   │   ┌───────────────────┐   │   │   │
                                │   │   │   │       CODE        │   │   │   │
                                │   │   │   └───────────────────┘   │   │   │
                                │   │   └───────────────────────────┘   │   │
                                │   └───────────────────────────────────┘   │
                                └───────────────────────────────────────────┘
```

![](images/kubernetes/Secure-Your-Kubernetes-Cluster-1024x586.png){height="220px"}

### 1. Authentification & RBAC (Qui a le droit de faire quoi ?)

```
   SUJETS                     RÔLES                           PORTÉES
  (Qui ?)                   (Quoi ?)                         (Où ?)
     │                         │                               │
┌────┴────────────┐       ┌────┴────────────┐             ┌────┴──────────────┐
│ User / Group    │ ────► │ Verbs : get,    │ ──────────► │ RoleBinding       │
│ ServiceAccount  │       │ list, create... │             │ (Namespace local) │
└─────────────────┘       │ Resources: pods │             ├───────────────────┤
                          └─────────────────┘             │ ClusterRoleBinding│
                                                          │ (Tout le Cluster) │
                                                          └───────────────────┘
```

![](images/kubernetes/rbac.svg){height="200px"}

### Exemple de Règle RBAC Moindre Privilège

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: production
  name: pod-log-viewer
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  namespace: production
  name: dev-view-logs
subjects:
- kind: Group
  name: developers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-log-viewer
  apiGroup: rbac.authorization.k8s.io
```

### 2. Pod Security Standards (PSA / PSS)

Les vieux `PodSecurityPolicy` (PSP) sont dépréciés. Le standard moderne est **Pod Security Admission** :

| Profil PSS | Niveau de Sécurité | Restrictions Imposées |
| :--- | :--- | :--- |
| **`Privileged`** | 🔓 Insecure | Accès complet sans restriction (réservé aux CNI / CSI) |
| **`Baseline`** | 🟡 Standard | Interdit les conteneurs privilégiés et accès hostPath critiques |
| **`Restricted`** | 🔒 Durci (Prod) | Non-root obligatoire, capabilities supprimées, FS en lecture seule |

```bash
# Activer le mode Restricted sur un namespace en 1 commande :
kubectl label namespace production \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/warn=restricted
```

### 3. Durcissement du Pod : SecurityContext

```yaml
spec:
  securityContext:
    runAsNonRoot: true       # Interdit l'exécution sous root (UID 0)
    seccompProfile:
      type: RuntimeDefault   # Active le filtrage des appels système
  containers:
  - name: app
    image: my-app:distroless
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true  # Empêche l'écriture de malware
      capabilities:
        drop: ["ALL"]               # Supprime toutes les capacités Linux
```

### 4. Network Policies : Le Pare-feu Interne (Zero Trust)

Par défaut dans Kubernetes, **tous les Pods peuvent parler à tous les Pods** !

```yaml
# Règle d'or : Bloquer tout le trafic entrant par défaut (Default Deny)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: production
spec:
  podSelector: {}  # S'applique à tous les pods du namespace
  policyTypes:
  - Ingress
```

```yaml
# N'autoriser QUE le Backend à parler à PostgreSQL sur le port 5432
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-to-postgres
spec:
  podSelector:
    matchLabels:
      app: postgres
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: bookstore-backend
    ports:
    - protocol: TCP
      port: 5432
```

### Mini-Défi : L'Erreur d'Audit de Sécurité

**Question flash** : Quelle commande `kubectl` permet de vérifier immédiatement si l'utilisateur `alice` a le droit de supprimer des secrets dans le namespace `production` ?


### Mini-Défi : L'Erreur d'Audit de Sécurité

**Question flash** : Quelle commande `kubectl` permet de vérifier immédiatement si l'utilisateur `alice` a le droit de supprimer des secrets dans le namespace `production` ?

```bash
# La réponse instantanée :
kubectl auth can-i delete secrets -n production --as alice
```

