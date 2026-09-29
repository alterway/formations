### Exercice 1/30 : Pod bloqué en `ImagePullBackOff` (Niveau : Très facile)

* **Objectif :** Diagnostiquer et résoudre un échec de récupération d'image de conteneur.
* **Contexte :** Le déploiement d'un serveur web NGINX échoue dès son instanciation sur le vcluster.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : Le tag spécifié pour l'image NGINX n'existe pas sur le registre.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-frontend
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-frontend
  template:
    metadata:
      labels:
        app: web-frontend
    spec:
      containers:
      - name: nginx
        # ERREUR : Ce tag d'image est fictif et provoque l'échec de pull
        image: nginx:1.25.999-alpine
        ports:
        - containerPort: 80

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-frontend
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-frontend
  template:
    metadata:
      labels:
        app: web-frontend
    spec:
      containers:
      - name: nginx
        # CORRECTION : Utilisation d'une version d'image valide et existante
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80

```

**Démarche de résolution pour l'apprenant :**

1. Inspecter le statut des ressources : `kubectl get pods` (statut `ErrImagePull` ou `ImagePullBackOff`).
2. Identifier la cause exacte : `kubectl describe pod <nom-du-pod>` puis analyser les événements en bas de page (`Failed to pull image... manifest unknown`).
3. Corriger le manifeste ou patcher le déploiement : `kubectl set image deployment/web-frontend nginx=nginx:1.25-alpine`.

---
