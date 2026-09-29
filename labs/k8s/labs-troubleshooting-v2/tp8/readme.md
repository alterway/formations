### Exercice 8/30 : Erreur Ingress (HTTP 502 Bad Gateway) due à un port Service mal configuré (Niveau : Facile / Moyen)

* **Objectif :** Diagnostiquer une rupture d'acheminement du trafic HTTP au niveau de la ressource Ingress.
* **Contexte :** L'Ingress Controller renvoie une erreur `502 Bad Gateway` lorsque l'on tente d'accéder à l'application web exposée.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : L'Ingress tente d'envoyer le trafic sur le port 8080 du Service, alors que le Service n'expose que le port 80.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: default
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: web-app
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: default
spec:
  ingressClassName: nginx
  rules:
  - host: app.vcluster.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              # ERREUR : Le Service "web-service" n'a aucun port 8080 défini
              number: 8080

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: default
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: web-app
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: default
spec:
  ingressClassName: nginx
  rules:
  - host: app.vcluster.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              # CORRECTION : Alignement du port sur celui exposé par le Service (80)
              number: 80

```

**Démarche de résolution pour l'apprenant :**

1. Recette ou test HTTP : constater la réponse HTTP 502 / 503 lors de la requête vers l'hôte Ingress.
2. Vérifier la ressource Ingress : `kubectl describe ingress web-ingress`.
3. Vérifier les objets Service et Endpoints ciblés : `kubectl describe svc web-service`.
4. Comparer le port déclaré dans `spec.rules[].http.paths[].backend.service.port.number` de l'Ingress avec la liste `Ports:` du Service `web-service`.
5. Corriger le numéro de port dans le manifeste Ingress pour correspondre au port exposé par le Service.

---

Valides-tu cet exercice 8 pour passer à l'exercice 9 ?