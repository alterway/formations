### Exercice 4/30 : Service inaccessible sans Endpoints associés (Niveau : Facile)

* **Objectif :** Diagnostiquer une rupture de routage réseau due à un désalignement de labels (*selector*) entre un Service et ses Pods.
* **Contexte :** Une application est déployée avec un Service ClusterIP, mais les requêtes réseau vers l'adresse du Service tombent en *timeout*.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : Le sélecteur du Service contient une coquille ("app-web") qui ne correspond pas aux labels du Pod ("app: web-server").
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-server
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-server
  template:
    metadata:
      labels:
        app: web-server
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: default
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
  selector:
    # ERREUR : Le label ne correspond pas à "app: web-server"
    app: app-web

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-server
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-server
  template:
    metadata:
      labels:
        app: web-server
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: default
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
  selector:
    # CORRECTION : Le sélecteur cible le bon label défini sur les Pods
    app: web-server

```

**Démarche de résolution pour l'apprenant :**

1. Tester la joignabilité du Service ou inspecter ses *Endpoints* : `kubectl get endpoints web-service`.
2. Observer que la liste *ENDPOINTS* affiche `<none>`.
3. Vérifier les labels portés par les Pods du déploiement : `kubectl get pods --show-labels`.
4. Inspecter le manifeste du Service : `kubectl describe svc web-service` et comparer la ligne *Selector* avec les labels réels des Pods.
5. Corriger le *selector* du Service.

---
