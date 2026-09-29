### Exercice 12/30 : Pod bloqué dans l'état `Init:0/1` (Niveau : Moyen)

* **Objectif :** Diagnostiquer et corriger un échec d'exécution dans la phase d'initialisation d'un Pod (*InitContainer*).
* **Contexte :** Le déploiement d'une application web dépend de la présence d'un service de base de données. Le conteneur applicatif principal ne démarre jamais et le Pod reste bloqué en `Init:0/1` (ou `Init:CrashLoopBackOff`).

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : L'InitContainer tente de contacter "db-postgres-svc" qui n'existe pas (le vrai Service s'appelle "db-svc").
apiVersion: v1
kind: Service
metadata:
  name: db-svc
  namespace: default
spec:
  ports:
  - port: 5432
    targetPort: 5432
  selector:
    app: db
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      initContainers:
      - name: wait-for-db
        image: alpine/k8s:1.37.0
        # ERREUR : Le nom du Service interrogé ("db-postgres-svc") est incorrect
        command: ['sh', '-c', 'until nc -z -w 2 db-postgres-svc 5432; do echo waiting for db; sleep 2; done']
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: v1
kind: Service
metadata:
  name: db-svc
  namespace: default
spec:
  ports:
  - port: 5432
    targetPort: 5432
  selector:
    app: db
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      initContainers:
      - name: wait-for-db
        image: alpine/k8s:1.37.0
        # CORRECTION : Alignement du nom de domaine interne sur le Service existant "db-svc"
        command: ['sh', '-c', 'until nc -z -w 2 db-svc 5432; do echo waiting for db; sleep 2; done']
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80

```

**Démarche de résolution pour l'apprenant :**

1. Lister les Pods : `kubectl get pods` (observer le statut `Init:0/1` ou `Init:Error`).
2. Consulter les détails du Pod : `kubectl describe pod <nom-du-pod>`. La section *Init Containers* indique la commande exécutée et l'état de santé du conteneur d'init.
3. Extraire les logs spécifiquement pour l'InitContainer : `kubectl logs <nom-du-pod> -c wait-for-db`.
4. Constater que la résolution DNS du nom d'hôte ou la tentative d'ouverture du socket TCP vers `db-postgres-svc` échoue.
5. Lister les services du namespace : `kubectl get svc` pour identifier le bon nom (`db-svc`).
6. Corriger la commande du conteneur d'initialisation dans le manifeste.

---
