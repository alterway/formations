### Exercice 13/30 : Échec d'écriture sur un volume persistant dû au `securityContext` (`Permission Denied`) (Niveau : Moyen)

* **Objectif :** Diagnostiquer et corriger un problème de droits d'accès système (UID/GID) lors du montage d'un volume persistant avec un conteneur non-root.
* **Contexte :** Une application configurée pour s'exécuter avec un utilisateur non privilégié (`UID 10001`) plante au démarrage car elle ne parvient pas à écrire ses logs dans le volume PVC monté.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : Le conteneur s'exécute avec l'UID 10001, mais le volume monté appartient par défaut à root (0:0). Sans fsGroup, l'écriture est refusée.
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-storage-pvc
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
  name: secure-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      securityContext:
        runAsUser: 10001
        runAsGroup: 10001
        # ERREUR : Absence de directive "fsGroup". Le répertoire monté appartiendra à root:root (0:0)
      containers:
      - name: app
        image: alpine:3.19
        command: ["sh", "-c", "echo 'initialization' > /var/app/data/status.log && sleep 3600"]
        volumeMounts:
        - name: data-vol
          mountPath: /var/app/data
      volumes:
      - name: data-vol
        persistentVolumeClaim:
          claimName: app-storage-pvc

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-storage-pvc
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
  name: secure-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      securityContext:
        runAsUser: 10001
        runAsGroup: 10001
        # CORRECTION : Définition du fsGroup. Kubernetes modifiera le groupe propriétaire du volume monté vers GID 10001
        fsGroup: 10001
      containers:
      - name: app
        image: alpine:3.19
        command: ["sh", "-c", "echo 'initialization' > /var/app/data/status.log && sleep 3600"]
        volumeMounts:
        - name: data-vol
          mountPath: /var/app/data
      volumes:
      - name: data-vol
        persistentVolumeClaim:
          claimName: app-storage-pvc

```

**Démarche de résolution pour l'apprenant :**

1. Observer l'échec de démarrage : `kubectl get pods` (statut `CrashLoopBackOff` ou `Error`).
2. Consulter les journaux d'erreurs : `kubectl logs deployment/secure-app`. L'erreur explicite s'affiche : `sh: can't create /var/app/data/status.log: Permission denied`.
3. Analyser la configuration de sécurité du Pod : `kubectl get deployment secure-app -o yaml` et noter le paramètre `securityContext.runAsUser: 10001`.
4. Identifier l'absence de `fsGroup` dans le `securityContext` au niveau Pod, ce qui empêche Kubernetes de transférer la propriété du système de fichiers du volume au groupe de l'utilisateur non-root.
5. Ajouter `fsGroup: 10001` sous `spec.template.spec.securityContext` et réappliquer le manifeste.

---
