### Authentication & Autorisation 

- RBAC (Role Based Access Control)
- ABAC (Attribute-based access control)
- WebHook
- Certificates
- Token


### RBAC

- 3 entités sont utilisées :

    - Utilisateurs représentés par les `Users` ou les `ServiceAccounts`
    - Resources représentées par les `Deployments`, `Pods`, `Services`, etc...
    - les différentes opérations possibles : `create, list, get, delete, watch, patch`


### Service Accounts

- Objet Kubernetes permettant d'identifier une application s'éxecutant dans un pod
- Par défaut, un `ServiceAccount` par `namespace`
- Le `ServiceAccount` est formatté ainsi :
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

- L'objet `Role` est un ensemble de règles permettant de définir quelle opération (ou _verbe) peut être effectuée et sur quelle ressource
- Le `Role` ne s'applique qu'à un seul `namespace` et les ressources liées à ce `namespace`


### Role

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
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

- L'objet `ClusterRole` est similaire au `Role` à la différence qu'il n'est pas limité à un seul `namespace`
- Il permet d'accéder à des ressources non limitées à un `namespace` comme les `nodes`

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

```yaml
 kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: salme-reads-all-pods
subjects:
- kind: User
  name: jsalmeron
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```


### RBAC

```
kubectl auth can-i get pods /
--namespace=default /
--as=spesnova@example.com
```


### NetworkPolicies

- La ressource `NetworkPolicy` est une spécification permettant de définir comment un ensemble de `pods` communiquent entre eux ou avec d'autres endpoints
- Le `NetworkPolicy` utilisent les labels pour sélectionner les pods sur lesquels s'appliquent les règles qui définissent le trafic alloué sur les pods sélectionnés
- Le `NetworkPolicy` est générique et fait partie de l'API Kubernetes. Il est nécessaire que le plugin réseau déployé supporte cette spécification

### NetworkPolicies

- DENY tout le trafic sur une application
- LIMIT le trafic sur une application 
- DENY le trafic all non alloué dans un namespace
- DENY tout le trafic venant d'autres namespaces
- exemples de Network Policies : <https://github.com/ahmetb/kubernetes-network-policy-recipes>

### NetworkPolicies

- Exemple de `NetworkPolicy` permettant de blocker le trafic entrant :

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

### PodSecurityPolicies

- Nécessite d'être activés spécifiquement
- Permet de définir ce qui est alloué pour l'éxecution
- Il faut une PSP par défaut
- A utiliser dans un contexte multitenant
- Peut-être combiné avec le RBAC
- Attention: Activer cette fonctionnalité peut endommager votre environnement


### Admission Controllers

- Interceptes les requêtes sur l'API Kubernetes
- Peut effectuer des modifications si nécessaires
- Conception personnalisée possible


### Admission Controllers

- `DenyEscalatingExec`
- `ImagePolicyWebhook`
- `NodeRestriction`
- `PodSecurityPolicy`
- `SecurityContextDeny`
- `ServiceAccount`


