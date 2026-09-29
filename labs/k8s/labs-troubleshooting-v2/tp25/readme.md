### Exercice 25/30 : Plante au démarrage suite au verrouillage du système de fichiers (`readOnlyRootFilesystem`) (Niveau : Avancé / Expert)

* **Objectif :** Diagnostiquer et corriger un crash applicatif causé par une politique de durcissement de sécurité (`readOnlyRootFilesystem: true`) bloquant l'écriture de fichiers temporaires ou de PID.
* **Contexte :** Une équipe Sécurité a appliqué des exigences de durcissement (type CIS Benchmark) sur le déploiement d'un serveur web NGINX. Dès le lancement, le Pod entre en `CrashLoopBackOff` car NGINX ne peut plus écrire ses fichiers de processus (`/var/run/nginx.pid`) et de cache HTTP.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : "readOnlyRootFilesystem: true" rend l'intégralité du système de fichiers du conteneur immuable.
# NGINX plante immédiatement car il tente d'écrire /var/run/nginx.pid et d'initialiser /var/cache/nginx.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hardened-web
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hardened-web
  template:
    metadata:
      labels:
        app: hardened-web
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        securityContext:
          # ERREUR : Le système de fichiers est verrouillé en lecture seule sans fournir de volumes temporaires pour les répertoires d'écriture obligatoires
          readOnlyRootFilesystem: true
        ports:
        - containerPort: 80

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hardened-web
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hardened-web
  template:
    metadata:
      labels:
        app: hardened-web
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        securityContext:
          readOnlyRootFilesystem: true
        ports:
        - containerPort: 80
        volumeMounts:
        # CORRECTION : Montage de volumes enregistrés en mémoire vive (emptyDir) sur les points d'écriture nécessaires
        - name: run-vol
          mountPath: /var/run
        - name: cache-vol
          mountPath: /var/cache/nginx
      volumes:
      - name: run-vol
        emptyDir: {}
      - name: cache-vol
        emptyDir: {}

```

**Démarche de résolution pour l'apprenant :**

1. Inspecter le statut des Pods : `kubectl get pods` (statut `CrashLoopBackOff` ou `Error`).
2. Consulter les journaux d'erreurs du conteneur : `kubectl logs deployment/hardened-web`.
3. Analyser le message de l'exécutable NGINX : `[emerg] 1#1: open() "/var/run/nginx.pid" failed (30: Read-only file system)`.
4. Examiner le `securityContext` dans la spécification du Pod : `kubectl get deployment hardened-web -o yaml`.
5. Identifier la présence de `readOnlyRootFilesystem: true`.
6. Ajouter des volumes `emptyDir` ciblés dans la section `volumeMounts` pour désigner les répertoires éphémères nécessaires au fonctionnement du binaire (`/var/run` et `/var/cache/nginx`) tout en conservant la contrainte de sécurité immuable sur le reste de la racine.

---

Valides-tu cet exercice 25 pour passer à l'exercice 26 ?