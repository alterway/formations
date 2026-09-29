### Exercice 6/30 : Pod bloqué en `Pending` par surévaluation des ressources CPU (Niveau : Facile)

* **Objectif :** Diagnostiquer un échec d'ordonnancement (*scheduling*) lié à des demandes de ressources (*requests*) incompatibles avec les capacités des nœuds.
* **Contexte :** Un worker de traitement d'arrière-plan a été mis à jour par un développeur, mais la nouvelle version refuse de se lancer et reste bloquée en `Pending`.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : La requête CPU demande 100 cœurs au lieu de 100 millicœurs (100m), ce qu'aucun nœud ne peut satisfaire.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: worker-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: worker-app
  template:
    metadata:
      labels:
        app: worker-app
    spec:
      containers:
      - name: worker
        image: redis:7-alpine
        resources:
          requests:
            # ERREUR : "100" signifie 100 cœurs CPU entiers (coquille pour 100m)
            cpu: "100"
            memory: "128Mi"
          limits:
            cpu: "100"
            memory: "256Mi"

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: worker-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: worker-app
  template:
    metadata:
      labels:
        app: worker-app
    spec:
      containers:
      - name: worker
        image: redis:7-alpine
        resources:
          requests:
            # CORRECTION : Utilisation de la notation millicœurs (100m = 0.1 CPU)
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "200m"
            memory: "256Mi"

```

**Démarche de résolution pour l'apprenant :**

1. Constater que le Pod ne démarre pas : `kubectl get pods` (statut `Pending`, pas de nœud assigné dans la colonne *NODE* via `kubectl get pods -o wide`).
2. Diagnostiquer la cause de l'échec de scheduling : `kubectl describe pod <nom-du-pod>`.
3. Analyser la ligne dans la section *Events* : `0/X nodes are available: X Insufficient cpu.`
4. Analyser les ressources demandées par le Pod (`kubectl get pod <nom-du-pod> -o yaml` ou `describe`) et identifier l'erreur d'unité dans `requests.cpu`.
5. Ajuster le manifeste et appliquer la correction.

---
