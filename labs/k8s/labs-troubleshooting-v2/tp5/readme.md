### Exercice 5/30 : PersistentVolumeClaim bloqué en `Pending` (Niveau : Facile)

* **Objectif :** Diagnostiquer et corriger un problème d'allocation de volume persistant lié à un nom de `storageClassName` invalide.
* **Contexte :** Une base de données PostgreSQL ne démarre pas car son volume de stockage n'arrive pas à être provisionné.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : Le PVC demande une StorageClass "fast-ssd" non définie dans le cluster.
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: db-data-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  # ERREUR : La StorageClass "fast-ssd" n'existe pas
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db-server
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db-server
  template:
    metadata:
      labels:
        app: db-server
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        env:
        - name: POSTGRES_PASSWORD
          value: secretpassword
        volumeMounts:
        - mountPath: /var/lib/postgresql/data
          name: db-storage
      volumes:
      - name: db-storage
        persistentVolumeClaim:
          claimName: db-data-pvc

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: db-data-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  # CORRECTION : Utilisation de la classe de stockage standard disponible
  storageClassName: standard
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db-server
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db-server
  template:
    metadata:
      labels:
        app: db-server
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        env:
        - name: POSTGRES_PASSWORD
          value: secretpassword
        volumeMounts:
        - mountPath: /var/lib/postgresql/data
          name: db-storage
      volumes:
      - name: db-storage
        persistentVolumeClaim:
          claimName: db-data-pvc

```

**Démarche de résolution pour l'apprenant :**

1. Inspecter les Pods : `kubectl get pods` (statut `Pending`).
2. Vérifier les objets PVC : `kubectl get pvc` (statut `Pending`).
3. Diagnostiquer la cause via `kubectl describe pvc db-data-pvc`. Le message affiche : `storageclass.storage.k8s.io "fast-ssd" not found`.
4. Lister les StorageClasses disponibles dans le cluster : `kubectl get storageclass` (ou `sc`).
5. Corriger la spécification du PVC en indiquant la bonne `storageClassName` (ex. `standard`) puis réappliquer le manifeste.

---

