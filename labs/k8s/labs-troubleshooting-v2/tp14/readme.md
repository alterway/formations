### Exercice 14/30 : Déploiement bloqué en cours de mise à jour (*Rollout Stuck*) (Niveau : Moyen)

* **Objectif :** Diagnostiquer et débloquer une stratégie de mise à jour progressive (*RollingUpdate*) figée en raison d'une *readiness probe* défaillante sur les nouveaux Pods.
* **Contexte :** Une nouvelle version d'un composant web a été appliquée dans le cluster via `kubectl apply`. L'opération de mise à jour s'interrompt sans aller à son terme (`kubectl rollout status` tourne en boucle), empêchant le remplacement des anciennes instances.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : La sonde "readinessProbe" vérifie la route "/ready", mais NGINX ne renvoie qu'un code 404. Le Pod n'est jamais déclaré "Ready", ce qui bloque la progression du Rollout.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
  namespace: default
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: api-service
  template:
    metadata:
      labels:
        app: api-service
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            # ERREUR : La route /ready n'existe pas dans le conteneur NGINX (404 Not Found)
            path: /ready
            port: 80
          initialDelaySeconds: 2
          periodSeconds: 5

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
  namespace: default
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: api-service
  template:
    metadata:
      labels:
        app: api-service
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            # CORRECTION : Ciblage de la route "/" accessible qui renvoie un HTTP 200
            path: /
            port: 80
          initialDelaySeconds: 2
          periodSeconds: 5

```

**Démarche de résolution pour l'apprenant :**

1. Constater le blocage lors de l'exécution de la commande de suivi : `kubectl rollout status deployment/api-service`.
2. Inspecter les Pods créés par le déploiement : `kubectl get pods -l app=api-service`.
3. Noter qu'un nouveau Pod est au statut `Running` mais que sa colonne `READY` indique `0/1`.
4. Examiner les événements du Pod non disponible : `kubectl describe pod <nom-du-nouveau-pod>`.
5. Identifier le message dans la section *Events* : `Readiness probe failed: HTTP probe failed with statuscode: 404`.
6. Corriger le chemin HTTP de la *readiness probe* dans le manifeste et appliquer la mise à jour (ou effectuer un `kubectl rollout undo deployment/api-service` pour annuler d'abord le déploiement bloqué).

---

Valides-tu cet exercice 14 pour passer à l'exercice 15 ?