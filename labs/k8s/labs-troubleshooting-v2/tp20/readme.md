### Exercice 20/30 : Blocage de la création de Pods par un Webhook d'admission défaillant (`ValidatingWebhookConfiguration`) (Niveau : Avancé)

* **Objectif :** Diagnostiquer et résoudre un blocage au niveau du plan de contrôle (*Admission Control*) causé par un Webhook de validation inaccessible configuré en mode strict (`failurePolicy: Fail`).
* **Contexte :** Un webhook de validation personnalisé a été déployé pour contrôler la conformité des ressources dans le vcluster. À la suite d'un incident sur le Pod du webhook, toute tentative de création ou de mise à jour de Pod dans le cluster est rejetée par l'API Server.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : Le Webhook interceptant les créations de Pods pointe vers le service "validator-svc" qui n'a pas de Pods actifs (ou n'existe pas).
# Avec "failurePolicy: Fail", l'API Server rejette systématiquement la création de TOUT nouveau Pod.
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: strict-pod-validation
webhooks:
  - name: validate.pod.security.local
    rules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE"]
        resources: ["pods"]
        scope: "Namespaced"
    clientConfig:
      service:
        name: validator-svc
        namespace: default
        path: "/validate"
        port: 443
    # ERREUR : Si le service validator-svc ne répond pas, l'API Server refuse la création du Pod au lieu d'ignorer
    failurePolicy: Fail
    sideEffects: None
    admissionReviewVersions: ["v1"]
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: business-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: business-app
  template:
    metadata:
      labels:
        app: business-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
# Correction : Passage de failurePolicy de "Fail" à "Ignore" pour ne pas bloquer les déploiements en cas d'indisponibilité du contrôleur de validation (ou déploiement du service de validation).
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: strict-pod-validation
webhooks:
  - name: validate.pod.security.local
    rules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE"]
        resources: ["pods"]
        scope: "Namespaced"
    clientConfig:
      service:
        name: validator-svc
        namespace: default
        path: "/validate"
        port: 443
    # CORRECTION : En cas d'échec de communication avec le Webhook, l'API Server autorise l'opération
    failurePolicy: Ignore
    sideEffects: None
    admissionReviewVersions: ["v1"]
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: business-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: business-app
  template:
    metadata:
      labels:
        app: business-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine

```

**Démarche de résolution pour l'apprenant :**

1. Tenter d'appliquer un déploiement ou de créer un Pod de test (`kubectl apply -f ...` ou `kubectl run test --image=alpine`).
2. Observer l'erreur explicite retournée immédiatement par la commande `kubectl` :
`Internal error occurred: failed calling webhook "validate.pod.security.local": failed to call webhook: Post "[https://validator-svc.default.svc:443/validate](https://validator-svc.default.svc:443/validate)?...": service "validator-svc" not found` (ou connection refused).
3. Comprendre que le blocage se situe au niveau de la phase d'admission (avant le scheduling et la création du Pod).
4. Lister les webhooks enregistrés sur le cluster : `kubectl get validatingwebhookconfigurations` (ou `mutatingwebhookconfigurations`).
5. Examiner la configuration fautive : `kubectl describe validatingwebhookconfiguration strict-pod-validation`.
6. Résoudre l'incident soit en supprimant le webhook obsolète (`kubectl delete validatingwebhookconfiguration strict-pod-validation`), soit en passant son paramètre `failurePolicy` à `Ignore`, soit en restaurant le composant applicatif responsable de la validation.

---
