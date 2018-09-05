# Introduction au RBAC

RBAC : Role-Based Access Control
- 3 entités sont utilisées :
    - Utilisateurs représentés par les `Users` ou les `ServiceAccounts`
    - Resources représentées par les `Deployments`, `Pods`, `Services`, etc...
    - les différentes opérations possibles : `create, list, get, delete, watch, patch`

### Service Accounts

- ressource Kubernetes permettant d'identifier une application s'éxecutant dans un pod
- par défaut, un `ServiceAccount` par `namespace`
- le `ServiceAccount` est formatté ainsi :
    `system:serviceaccount:<namespace>:<service_account_name>`

### Service Accounts

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
    name: default
    namespace: default
```
### Role

- l'objet `Role` est un ensemble de règles permettant de définir quelle opération (ou _verbe) peut être effectuée et sur quelle ressource
- le `Role` ne s'applique qu'à un seul `namespace` et les ressources liées à ce `namespace`

### Role

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
  ```

### RoleBinding

- l'objet `RoleBinding` va allouer à un `User`, `ServiceAccount` ou un groupe les permissions dans l'objet `Role` associé
- Un objet `RoleBinding` doit référencer un `Role` dans le même `namespace`.
- l'objet `roleRef` spécifié dans le `RoleBinding` est celui qui crée le liaison

### RoleBinding

```yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role 
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
  ```

  ### ClusterRole

- l'objet `ClusterRole` est similaire au `Role` à la différence qu'il n'est pas limité à un seul `namespace`
- il permet d'accéder à des ressources non limitées à un `namespace` comme les `nodes`

### ClusterRole

```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
```

### ClusterRoleBinding

*TBD*


### Gestion des security contexts

### Gestion des secrets

### Introduction au Pod Security Policy

### Introduction au Network Policy

- La ressource `NetworkPolicy` est une spécification permettant de définir comment un ensemble de `pods` communiquent entre eux ou avec d'autres endpoints
- le `NetworkPolicy` utilisent les labels pour sélectionner les pods sur lesquels s'appliquent les règles qui définissent le trafic alloué sur les pods sélectionnés
- le `NetworkPolicy` est générique et fait partie de l'API Kubernetes. Il est nécessaire que le plugin réseau déployé supporte cette spécification

### NetworkPolicies

- exemple de `NetworkPolicy` permet de blocker le trafic entrant 
```yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: web-deny-all
spec:
  podSelector:
    matchLabels:
      app: web
  ingress: []
  ```
