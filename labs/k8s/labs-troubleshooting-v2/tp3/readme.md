### Exercice 3/30 : Pod en `CrashLoopBackOff` dû à une sonde d'état défaillante (Niveau : Facile)

* **Objectif :** Diagnostiquer et corriger une *liveness probe* mal configurée qui provoque l'arrêt redondant du conteneur.
* **Contexte :** Un service web NGINX est déployé mais le conteneur redémarre en boucle après une vingtaine de secondes.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : La sonde Liveness pointe sur un port et un chemin invalides.
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
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            # ERREUR : NGINX écoute sur le port 80 et ne répond pas sur /healthz par défaut
            path: /healthz
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
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
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            # CORRECTION : Ciblage du port 80 et de la racine '/' exposée par NGINX
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5

```

**Démarche de résolution pour l'apprenant :**

1. Observer les redémarrages fréquents du Pod : `kubectl get pods` (colonne *RESTARTS* augmente, statut `CrashLoopBackOff`).
2. Analyser l'historique des événements du Pod : `kubectl describe pod <nom-du-pod>`. La section *Events* affiche : `Liveness probe failed: Get "http://...:8080/healthz": dial tcp ... connection refused`.
3. Corriger le manifeste pour aligner le port et la route de la sonde sur la configuration réelle de l'application.

---
