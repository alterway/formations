### Exercice 2/30 : Pod bloqué en `CreateContainerConfigError` (Niveau : Très facile)

* **Objectif :** Diagnostiquer une dépendance manquante (ConfigMap non existante) empêchant l'initialisation du conteneur.
* **Contexte :** Une API backend ne parvient pas à créer son conteneur car elle tente de charger des variables d'environnement depuis une ressource inexistante dans le vcluster.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : Le déploiement fait référence à une ConfigMap "app-config-missing" qui n'a pas été déployée.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend-api
  template:
    metadata:
      labels:
        app: backend-api
    spec:
      containers:
      - name: api
        image: redis:7-alpine
        envFrom:
        # ERREUR : La ConfigMap référencée n'existe pas dans le namespace
        - configMapRef:
            name: app-config-missing

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
# Correction : Ajout du manifeste de la ConfigMap et alignement du nom dans le Deployment.
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: default
data:
  MAX_CONNECTIONS: "100"
  LOG_LEVEL: "info"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend-api
  template:
    metadata:
      labels:
        app: backend-api
    spec:
      containers:
      - name: api
        image: redis:7-alpine
        envFrom:
        # CORRECTION : Pointe vers la ConfigMap "app-config" réellement existante
        - configMapRef:
            name: app-config

```

**Démarche de résolution pour l'apprenant :**

1. Constater le problème avec `kubectl get pods` (statut `CreateContainerConfigError`).
2. Inspecter les événements du Pod : `kubectl describe pod <nom-du-pod>`. La section *Events* signale : `Error: configmap "app-config-missing" not found`.
3. Appliquer la ConfigMap manquante ou corriger la spécification du Deployment.

---
