# KUBERNETES : Sécurité et Contrôle d'accès

### Authentication & Autorisation


### Authentication 

Authentication (Qui êtes-vous ?):

- Vérifie l'identité de l'utilisateur
- Méthodes principales :

    - Certificats clients X.509
    - Tokens Bearer (JWT)
    - Service Accounts pour les pods
    - OpenID Connect / OAuth2
    - Fichiers de configuration statiques

**Résultat** : identité confirmée ou requête rejetée



### RBAC (Autorisation)


Authorization (Que pouvez-vous faire ?):

- Vérifie les permissions de l'utilisateur authentifié
- Utilise principalement RBAC (Role-Based Access Control)
- Composants clés :

    - Roles : définissent les permissions dans un namespace
    - ClusterRoles : permissions à l'échelle du cluster
    - RoleBindings : lient les rôles aux utilisateurs dans un namespace
    - ClusterRoleBindings : lient les rôles aux utilisateurs au niveau cluster

3 entités sont utilisées :

- Utilisateurs représentés par les `Users` ou les `ServiceAccounts`
- Ressources représentées par les `Deployments`, `Pods`, `Services`, etc...
- les différentes opérations possibles : `create, list, get, delete, watch, patch`


### RBAC

- L'authentification précède toujours l'autorisation
- Une requête doit passer les deux contrôles pour être acceptée
- Les deux mécanismes sont indépendants mais complémentaires
- RBAC est le standard de facto pour l'autorisation dans Kubernetes

![](images/kubernetes/rbac.svg){height="250px"}


### Service Accounts

- Objet Kubernetes permettant d'identifier une application s'exécutant dans un pod
- Par défaut, un `ServiceAccount` par `namespace`
- Le `ServiceAccount` est formatté ainsi : `system:serviceaccount:<namespace>:<service_account_name>`


### Service Accounts

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
    name: default
    namespace: default
```

### Role

- L'objet `Role` est un ensemble de règles permettant de définir quelle opération (ou _verbe_) peut être effectuée et sur quelle ressource
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

- L'objet `RoleBinding` va allouer à un `User`, `ServiceAccount` ou un groupe les permissions dans l'objet `Role` associé
- Un objet `RoleBinding` doit référencer un `Role` dans le même `namespace`.
- L'objet `roleRef` spécifié dans le `RoleBinding` est celui qui crée le liaison

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

```bash
kubectl auth can-i get pods /
--namespace=default /
--as=spesnova@example.com
```


### NetworkPolicies

![](images/kubernetes/Secure-Your-Kubernetes-Cluster-1024x586.png)


### NetworkPolicies

- La ressource `NetworkPolicy` est une spécification permettant de définir comment un ensemble de `pods` communiquent entre eux ou avec d'autres endpoints

- Le `NetworkPolicy` utilisent les labels pour sélectionner les pods sur lesquels s'appliquent les règles qui définissent le trafic alloué sur les pods sélectionnés
  
- Le `NetworkPolicy` est générique et fait partie de l'API Kubernetes. Il est nécessaire que le plugin réseau déployé supporte cette spécification


### NetworkPolicies

- DENY tout le trafic sur une application
- LIMIT le trafic sur une application
- DENY les trafic entrant et sortant dans un namespace
- DENY tout le trafic venant d'autres namespaces
- exemples de Network Policies : <https://github.com/ahmetb/kubernetes-network-policy-recipes>


### NetworkPolicies

- Exemple de `NetworkPolicy` permettant de bloquer le trafic entrant :

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

### NetworkPolicies : outils : Cilium Network Policy Editor

Cilium Network Policy Editor : <https://editor.networkpolicy.io/?id=xJYCeLwGmAGxTqjm>

![cilium](images/kubernetes/npp1.png){height="400px"}

    

### NetworkPolicies : outils : Tufin Network Policy Viewer

Tufin Network Policy Viewer : <https://orca.tufin.io/netpol/>


![tufin](images/kubernetes/npp2.png){height="400px"}
    



### NetworkPolicies : outils : Kubernetes NetworkPolicy viewer

Kubernetes NetworkPolicy viewer : <https://artturik.github.io/network-policy-viewer/>

![npg](images/kubernetes/npp3.png){height="400px"}

    



### Pod Security Admission

Alpha en 1.22, GA depuis la 1.25

Plus simple que les PSP.

- S'appuie sur les standards de sécurité des pods (Pod Security Standards - PSS).
- Définit trois politiques :
    - **privileged** (peut tout faire ; pour les composants système)
        - peut tout faire 
    - **restricted** (pas d'utilisateur root ; presque aucune capacité)
        - La politique Restricted vise à appliquer les meilleures pratiques actuelles de renforcement des Pods, au détriment d'une certaine compatibilité. 
        - Elle est destinée aux opérateurs et développeurs d'applications critiques pour la sécurité, ainsi qu'aux utilisateurs à faible niveau de confiance.
    - **baseline** (intermédiaire avec des valeurs par défaut raisonnables)
        - La politique **Baseline** vise à faciliter l'adoption pour les charges de travail conteneurisées courantes tout en prévenant les escalades de privilèges connues.
        - Cette politique est destinée aux opérateurs d'applications et aux développeurs d'applications non critiques.
- 
- Labels sur les namespaces pour indiquer quelles politiques sont autorisées.
- Supporte également la définition de valeurs par défaut globales.
- Supporte les modes **enforce**, **audit** et **warn**.


    

### Pod Security Admission : Namespace labels  

Trois labels optionnels peuvent être ajoutés aux namespaces :

- pod-security.kubernetes.io/enforce
- pod-security.kubernetes.io/audit
- pod-security.kubernetes.io/warn

- enforce = empêche la création de pods
- warn = autorise la création mais inclut un avertissement dans la réponse de l'API
    (sera visible par exemple dans la sortie de kubectl)
- audit = autorise la création mais génère un événement d'audit de l'API
    (sera visible si l'audit de l'API a été activé et configuré)

Les valeurs possibles sont : 

- baseline, 
- restricted, 
- privileged

(définir la valeur à privileged n'a pas vraiment d'effet)


### Pod Security Admission : Exemple


```yaml 
apiVersion: v1
kind: Namespace
metadata:
  labels:
    kubernetes.io/metadata.name: formation-k8s
    pod-security.kubernetes.io/enforce: baseline
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
  name: formation-k8s

```

Les trois lignes suivantes définissent les labels: 


pod-security.kubernetes.io/enforce=baseline : 

    - Applique la politique de sécurité "baseline" en mode "enforce". 
    - Cela empêchera la création de pods qui ne respectent pas les critères de sécurité de base.
     
pod-security.kubernetes.io/audit=restricted : 

    - Configure l'audit en mode "restricted". 
    - Cela générera des événements d'audit pour les pods qui ne respectent pas les critères de sécurité restrictifs.
      
pod-security.kubernetes.io/warn=restricted : 

    - Active les avertissements en mode "restricted". 
    - Cela produira des avertissements lors de la création de pods qui ne respectent pas les critères de sécurité restrictifs.


    

### Pod Security Admission : Revenir en arriere 


```yaml
apiVersion: v1
kind: Namespace
metadata:
  labels:
    kubernetes.io/metadata.name: formation-k8s
    pod-security.kubernetes.io/enforce: privileged
    pod-security.kubernetes.io/audit: privileged
    pod-security.kubernetes.io/warn: privileged
  name: formation-k8s

```

- Typiquemement les pod dans kube-system doivent pouvoir être en mode privileged.
- Si vous ne définissez pas de PSA les pod privilégiés sont autorisés.
   


    

