### Exercice 17/30 : Conflit de volume persistant `Multi-Attach error` en multi-répliques (Niveau : Moyen / Avancé)

* **Objectif :** Diagnostiquer et corriger un blocage de Pod au statut `ContainerCreating` causé par l'utilisation d'un `Deployment` à plusieurs répliques partageant un volume `ReadWriteOnce` (RWO).
* **Contexte :** Un administrateur souhaite passer un service de stockage de fichiers à 2 instances. Le second Pod refuse de démarrer et reste indéfiniment au statut `ContainerCreating`.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : Un Deployment à 2 répliques référence le MÊME PVC en mode ReadWriteOnce (RWO).
# Le deuxième Pod ne peut pas attacher le volume car le stockage RWO est réservé à un seul nœud/Pod.
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: shared-data-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: file-uploader
  namespace: default
spec:
  # ERREUR : 2 répliques pour un Deployment partageant une seule PVC en mode ReadWriteOnce
  replicas: 2
  selector:
    matchLabels:
      app: file-uploader
  template:
    metadata:
      labels:
        app: file-uploader
    spec:
      containers:
      - name: storage-app
        image: nginx:1.25-alpine
        volumeMounts:
        - name: data-vol
          mountPath: /usr/share/nginx/html
      volumes:
      - name: data-vol
        persistentVolumeClaim:
          claimName: shared-data-pvc

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
# Correction : Conversion du Deployment en StatefulSet avec volumeClaimTemplates.
# Chaque réplique dispose désormais de sa propre PVC dédiée (data-vol-file-uploader-0, data-vol-file-uploader-1).
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: file-uploader
  namespace: default
spec:
  serviceName: "file-uploader"
  replicas: 2
  selector:
    matchLabels:
      app: file-uploader
  template:
    metadata:
      labels:
        app: file-uploader
    spec:
      containers:
      - name: storage-app
        image: nginx:1.25-alpine
        volumeMounts:
        - name: data-vol
          mountPath: /usr/share/nginx/html
  # CORRECTION : Génération automatique d'un PVC unique par instance de Pod
  volumeClaimTemplates:
  - metadata:
      name: data-vol
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: standard
      resources:
        requests:
          storage: 1Gi

```

**Démarche de résolution pour l'apprenant :**

1. Inspecter l'état des Pods : `kubectl get pods` (observer qu'une instance est `Running` et l'autre bloquée en `ContainerCreating`).
2. Examiner la raison du blocage : `kubectl describe pod <nom-du-pod-bloque>`.
3. Analyser les événements système : `Warning FailedAttachVolume ... Multi-Attach error for volume "pvc-..." Volume is already exclusively attached to one node`.
4. Identifier le problème d'architecture : un `Deployment` ne doit pas être utilisé avec un PVC `ReadWriteOnce` si `replicas > 1`, car les Pods ne peuvent pas tous verrouiller le même volume RWO.
5. Transformer l'architecture vers un `StatefulSet` avec `volumeClaimTemplates` (ou modifier le mode du volume en `ReadWriteMany` si le fournisseur de stockage le permet).

---
