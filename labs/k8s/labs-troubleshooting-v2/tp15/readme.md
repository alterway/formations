### Exercice 15/30 : HPA inopérant avec métriques à l'état `<unknown>` (Niveau : Moyen)

* **Objectif :** Diagnostiquer pourquoi un *HorizontalPodAutoscaler* (HPA) ne parvient pas à calculer la charge du déploiement et reste inactif.
* **Contexte :** Une politique d'autoscaling a été déployée pour absorber les pics de trafic d'un service web. Malgré une hausse de charge, le HPA ne dimensionne pas les Pods et affiche l'état `<unknown>/50%`.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : Le HPA est configuré pour se baser sur l'utilisation du CPU, mais les conteneurs du Deployment n'ont aucune demande ("requests.cpu") définie.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: autoscale-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: autoscale-app
  template:
    metadata:
      labels:
        app: autoscale-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
        # ERREUR : Pas de bloc "resources.requests" défini.
        # Le HPA ne peut pas calculer de pourcentage d'utilisation sans valeur de référence.
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: autoscale-app-hpa
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: autoscale-app
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: autoscale-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: autoscale-app
  template:
    metadata:
      labels:
        app: autoscale-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
        # CORRECTION : Ajout des requêtes de ressources CPU indispensables au calcul du HPA
        resources:
          requests:
            cpu: "100m"
            memory: "64Mi"
          limits:
            cpu: "200m"
            memory: "128Mi"
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: autoscale-app-hpa
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: autoscale-app
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50

```

**Démarche de résolution pour l'apprenant :**

1. Inspecter l'état de l'autoscaler : `kubectl get hpa autoscale-app-hpa`.
2. Observer la colonne `TARGETS` qui affiche `<unknown>/50%`.
3. Obtenir le détail des événements du HPA : `kubectl describe hpa autoscale-app-hpa`.
4. Lire le message d'avertissement (*Warning*) sous la section *Conditions* : `FailedGetResourceMetric: missing request for cpu in container nginx of Pod ...`.
5. Vérifier la spécification des ressources des Pods du Deployment : `kubectl get deployment autoscale-app -o yaml`.
6. Ajouter le bloc `resources.requests.cpu` dans le gabarit de Pod du Deployment et appliquer.

---

