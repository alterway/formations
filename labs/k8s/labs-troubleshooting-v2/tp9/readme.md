### Exercice 9/30 : Échec de création de Pods par dépassement de `ResourceQuota` (Niveau : Facile / Moyen)

* **Objectif :** Diagnostiquer un blocage au niveau de la planification des Pods causé par des restrictions de ressources sur le Namespace (`ResourceQuota`).
* **Contexte :** Une application ne crée aucun Pod lors du déploiement. Le Deployment apparaît avec 0 réplique disponible alors que le manifeste semble correct.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : Le Namespace impose un quota de mémoire maximale globale (500Mi), mais le Pod réclame 1Gi.
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mem-quota
  namespace: default
spec:
  hard:
    requests.memory: "500Mi"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: memory-heavy-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: memory-heavy-app
  template:
    metadata:
      labels:
        app: memory-heavy-app
    spec:
      containers:
      - name: app
        image: nginx:1.25-alpine
        resources:
          requests:
            # ERREUR : La requête (1Gi) dépasse le quota total toléré dans le Namespace (500Mi)
            memory: "1Gi"
            cpu: "100m"

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mem-quota
  namespace: default
spec:
  hard:
    requests.memory: "500Mi"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: memory-heavy-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: memory-heavy-app
  template:
    metadata:
      labels:
        app: memory-heavy-app
    spec:
      containers:
      - name: app
        image: nginx:1.25-alpine
        resources:
          requests:
            # CORRECTION : Ajustement de la mémoire sous la limite fixée par le ResourceQuota
            memory: "256Mi"
            cpu: "100m"

```

**Démarche de résolution pour l'apprenant :**

1. Lister les Pods : `kubectl get pods` (aucun Pod n'apparaît dans la liste).
2. Inspecter le contrôleur du déploiement : `kubectl get deployment memory-heavy-app`.
3. Analyser la ressource ReplicaSet sous-jacente : `kubectl get rs` puis `kubectl describe rs <nom-du-replicaset>`.
4. Inspecter le message d'erreur dans les événements du ReplicaSet : `exceeded quota: mem-quota, requested: requests.memory=1Gi, used: requests.memory=0, limited: requests.memory=500Mi`.
5. Consulter les quotas appliqués au namespace : `kubectl get resourcequota` et `kubectl describe quota mem-quota`.
6. Corriger le fichier de déploiement en abaissant la demande `requests.memory` sous la valeur max autorisée, ou réajuster le quota si la demande est légitime.

---
