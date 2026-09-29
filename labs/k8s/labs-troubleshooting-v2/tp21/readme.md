### Exercice 21/30 : Conflit de topologie de stockage et d'ordonnancement (*Volume Node Affinity Conflict*) (Niveau : Avancé)

* **Objectif :** Diagnostiquer un échec de planification (*scheduling*) d'un Pod lié à une incompatibilité entre la topologie d'un volume local (`nodeAffinity` du PV) et les contraintes de placement du Pod (`nodeSelector`).
* **Contexte :** Une base de données s'appuie sur un volume persistant local. Le Pod reste bloqué à l'état `Pending` avec une erreur indiquant un conflit de topologie entre le stockage et les nœuds disponibles.


kubectl label node <noeud-1> topology.kubernetes.io/zone=zone-a --overwrite
kubectl label node <noeud-2> topology.kubernetes.io/zone=zone-b --overwrite


```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : Le PersistentVolume est physiquement lié à la zone "zone-a", mais le Deployment force l'exécution du Pod sur les nœuds de la zone "zone-b".
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv-data
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /mnt/disks/data
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: topology.kubernetes.io/zone
          operator: In
          values:
          - zone-a
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc-data
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-storage
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stateful-db
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stateful-db
  template:
    metadata:
      labels:
        app: stateful-db
    spec:
      # ERREUR : Le nodeSelector force le Pod sur zone-b, ce qui entre en conflit direct avec la nodeAffinity du PV (zone-a)
      nodeSelector:
        topology.kubernetes.io/zone: zone-b
      containers:
      - name: db
        image: postgres:15-alpine
        env:
        - name: POSTGRES_PASSWORD
          value: secret
        volumeMounts:
        - mountPath: /var/lib/postgresql/data
          name: db-storage
      volumes:
      - name: db-storage
        persistentVolumeClaim:
          claimName: local-pvc-data

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv-data
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /mnt/disks/data
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: topology.kubernetes.io/zone
          operator: In
          values:
          - zone-a
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc-data
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-storage
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stateful-db
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stateful-db
  template:
    metadata:
      labels:
        app: stateful-db
    spec:
      # CORRECTION : Alignement du nodeSelector sur la zone géographique du PV (zone-a)
      nodeSelector:
        topology.kubernetes.io/zone: zone-a
      containers:
      - name: db
        image: postgres:15-alpine
        env:
        - name: POSTGRES_PASSWORD
          value: secret
        volumeMounts:
        - mountPath: /var/lib/postgresql/data
          name: db-storage
      volumes:
      - name: db-storage
        persistentVolumeClaim:
          claimName: local-pvc-data

```

**Démarche de résolution pour l'apprenant :**

1. Inspecter l'état des ressources : `kubectl get pods` (statut `Pending`).
2. Diagnostiquer la cause auprès du scheduler Kubernetes : `kubectl describe pod <nom-du-pod>`.
3. Analyser les événements sous *Events* : `0/N nodes are available: N node(s) had volume node affinity conflict`.
4. Inspecter les contraintes du PV attribué à la PVC : `kubectl describe pv local-pv-data` et vérifier le bloc `Node Affinity`.
5. Comparer la politique de topologie du PV (`topology.kubernetes.io/zone: zone-a`) avec la section `nodeSelector` ou `nodeAffinity` du Pod dans le Deployment (`topology.kubernetes.io/zone: zone-b`).
6. Corriger le manifeste pour aligner le placement du Pod sur le nœud ou la zone disposant du volume physique.

---

