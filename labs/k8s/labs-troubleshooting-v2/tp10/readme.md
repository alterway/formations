### Exercice 10/30 : Erreur de permission RBAC (`403 Forbidden`) dans un Pod (Niveau : Moyen)

* **Objectif :** Diagnostiquer et corriger une restriction de droits RBAC empêchant une application de communiquer avec l'API Kubernetes.
* **Contexte :** Un script d'inventaire s'exécute dans un Pod pour lister les ressources du Namespace, mais il échoue avec un code d'erreur HTTP 403 (`Forbidden`).

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : Le Pod utilise le ServiceAccount "default" qui ne possède aucun droit d'accès sur l'API Kubernetes.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: k8s-exporter
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: k8s-exporter
  template:
    metadata:
      labels:
        app: k8s-exporter
    spec:
      # ERREUR : Aucun serviceAccountName n'est spécifié, le pod prend "default" sans droits RBAC
      containers:
      - name: exporter
        image: alpine/k8s:1.37.0
        command: ["sh", "-c", "while true; do kubectl get pods; sleep 10; done"]

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
# Correction : Création d'un ServiceAccount, d'un Role RBAC et d'un RoleBinding associés au Pod.
apiVersion: v1
kind: ServiceAccount
metadata:
  name: exporter-sa
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader-role
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
RoleBinding
metadata:
  name: read-pods-binding
  namespace: default
subjects:
- kind: ServiceAccount
  name: exporter-sa
  namespace: default
roleRef:
  kind: Role
  name: pod-reader-role
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: k8s-exporter
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: k8s-exporter
  template:
    metadata:
      labels:
        app: k8s-exporter
    spec:
      # CORRECTION : Association du ServiceAccount disposant des droits de lecture
      serviceAccountName: exporter-sa
      containers:
      - name: exporter
        image: alpine/k8s:1.37.0
        command: ["sh", "-c", "while true; do kubectl get pods; sleep 10; done"]

```

**Démarche de résolution pour l'apprenant :**

1. Consulter les logs du Pod : `kubectl logs -f deployment/k8s-exporter`.
2. Constater l'erreur retournée par l'API Server : `Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:default:default" cannot list resource "pods" in API group "" in the namespace "default"`.
3. Identifier que le comptes de service utilisé (`default`) manque d'autorisations RBAC.
4. Créer la chaîne de ressources RBAC nécessaires (`ServiceAccount`, `Role`, `RoleBinding`) et mettre à jour `serviceAccountName` dans le manifeste du Deployment.

---

Valides-tu cet exercice 10 pour passer à l'exercice 11 ?