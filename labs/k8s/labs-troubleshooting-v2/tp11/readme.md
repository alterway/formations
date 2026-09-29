C'est bien noté pour l'image `alpine/k8s:1.37.0`, je l'utiliserai désormais à la place de Bitnami pour les prochains exercices nécessitant ce type d'outils.

Voici l'exercice 11, on entre dans la catégorie de difficulté moyenne.

### Exercice 11/30 : Flux inter-Pods bloqué par une NetworkPolicy (Niveau : Moyen)

* **Objectif :** Diagnostiquer une perte de connectivité réseau interne due à une stratégie de sécurité réseau (`NetworkPolicy`) mal ciblée.
* **Contexte :** Une application front-end n'arrive plus à joindre l'API back-end. Les deux Pods sont pourtant au statut `Running` et le Service du back-end est bien configuré.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : La NetworkPolicy du back-end autorise uniquement les flux entrants provenant des Pods avec le label "role: frontend", or le frontend possède "app: frontend".
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend-api
  template:
    metadata:
      labels:
        app: backend-api
    spec:
      containers:
      - name: api
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: backend-svc
  namespace: default
spec:
  selector:
    app: backend-api
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend-app
  template:
    metadata:
      labels:
        # NOTE : Le label du pod est "app: frontend-app"
        app: frontend-app
    spec:
      containers:
      - name: utils
        # Utilisation de l'image demandée pour éviter les soucis de licence
        image: alpine/k8s:1.37.0
        command: ["sleep", "3600"]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-backend-access
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: backend-api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          # ERREUR : Aucun Pod ne possède ce label, le trafic du frontend est donc "Drop"
          role: frontend
    ports:
    - protocol: TCP
      port: 80

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
# [...] Les déploiements et le service restent identiques
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-backend-access
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: backend-api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          # CORRECTION : Le label correspond désormais à celui défini sur le Deployment frontend-app
          app: frontend-app
    ports:
    - protocol: TCP
      port: 80

```

**Démarche de résolution pour l'apprenant :**

1. Valider que les Pods sont opérationnels : `kubectl get pods,svc`.
2. Tester manuellement la connectivité en ouvrant un shell dans le frontend : `kubectl exec -it deployment/frontend-app -- sh`, puis faire un `curl --connect-timeout 5 http://backend-svc`. Constater le timeout.
3. Vérifier la présence de règles réseau : `kubectl get networkpolicy` (ou `netpol`).
4. Analyser la règle : `kubectl describe netpol restrict-backend-access`. Observer la section *Allowing ingress traffic*.
5. Comparer le `podSelector` de la règle *from* avec les labels réels du Pod frontend (`kubectl get pod -l app=frontend-app --show-labels`).
6. Corriger le manifeste de la NetworkPolicy (ou ajouter le label manquant sur le frontend) puis réappliquer.

---

