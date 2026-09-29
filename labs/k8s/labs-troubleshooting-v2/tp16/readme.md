### Exercice 16/30 : Conflit de montage de fichier ConfigMap (`Is a directory`) (Niveau : Moyen / Avancé)

* **Objectif :** Diagnostiquer une erreur d'initialisation de système de fichiers causée par un montage de fichier individuel sans la directive `subPath`.
* **Contexte :** Un administrateur souhaite injecter un fichier de configuration personnalisé `nginx.conf` via une ConfigMap. Au lancement, le conteneur crash immédiatement en boucle.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : Le volume est monté sur le chemin "/etc/nginx/nginx.conf". Sans l'option "subPath", Kubernetes crée un RÉPERTOIRE nommé "nginx.conf" au lieu d'un fichier.
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-custom-config
  namespace: default
data:
  nginx.conf: |
    events { worker_connections 1024; }
    http {
      server {
        listen 80;
        location / {
          return 200 'Config custom chargee avec succes!\n';
        }
      }
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-custom
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-custom
  template:
    metadata:
      labels:
        app: nginx-custom
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: config-volume
          # ERREUR : Sans "subPath", Kubernetes va monter le volume entier en tant que dossier "/etc/nginx/nginx.conf"
          mountPath: /etc/nginx/nginx.conf
      volumes:
      - name: config-volume
        configMap:
          name: nginx-custom-config

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-custom-config
  namespace: default
data:
  nginx.conf: |
    events { worker_connections 1024; }
    http {
      server {
        listen 80;
        location / {
          return 200 'Config custom chargee avec succes!\n';
        }
      }
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-custom
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-custom
  template:
    metadata:
      labels:
        app: nginx-custom
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: config-volume
          mountPath: /etc/nginx/nginx.conf
          # CORRECTION : Préciser subPath pour cibler la clé spécifique et la monter comme un fichier individuel
          subPath: nginx.conf
      volumes:
      - name: config-volume
        configMap:
          name: nginx-custom-config

```

**Démarche de résolution pour l'apprenant :**

1. Inspecter l'état du Pod : `kubectl get pods` (statut `CrashLoopBackOff`).
2. Consulter les logs du conteneur en échec : `kubectl logs deployment/nginx-custom`.
3. Analyser le message d'erreur du binaire : `nginx: [emerg] open() "/etc/nginx/nginx.conf" failed (21: Is a directory)`.
4. Comprendre que la directive `mountPath` pointe sur un nom de fichier précis, mais que par défaut Kubernetes monte les ConfigMaps en tant que répertoires.
5. Corriger le manifeste en ajoutant `subPath: nginx.conf` sous la section `volumeMounts` de l'élément conteneur.

---

