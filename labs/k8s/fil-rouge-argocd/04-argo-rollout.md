## Étape 5 : Déploiement progressif avec Argo Rollouts

Argo Rollouts est un contrôleur Kubernetes dédié au suivi des stratégies de déploiement avancées (*Canary* et *Blue/Green*). Nous allons l'installer en respectant le principe GitOps : via un chart Helm piloté par une `Application` Argo CD.

---

### 1. Déploiement du contrôleur Argo Rollouts via Argo CD

Crée un fichier `argo-rollouts-app.yaml` pour ordonner à Argo CD de déployer le contrôleur dans le cluster :

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argo-rollouts
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io/foreground
spec:
  project: default
  source:
    repoURL: https://argoproj.github.io/argo-helm
    chart: argo-rollouts
    targetRevision: 2.38.0
    helm:
      values: |
        dashboard:
          enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: argo-rollouts
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true

```

Déploie l'application :

```bash
kubectl apply -f argo-rollouts-app.yaml

```

Vérifie que les pods de l'opérateur sont bien démarrés dans le namespace `argo-rollouts` :

```bash
kubectl get pods -n argo-rollouts

```

---

### 2. Installation du plugin CLI `kubectl argo rollouts`

Pour interagir facilement avec les ressources `Rollout` depuis ton terminal, installe le plugin officiel :

```bash
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
chmod +x ./kubectl-argo-rollouts-linux-amd64
sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts

```

---

### 3. Déploiement d'une application Canary de démonstration

Crée un fichier `rollout-demo.yaml` contenant une ressource `Rollout` qui remplace le `Deployment` standard :

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: rollout-demo
  namespace: guestbook-dev
spec:
  replicas: 5
  strategy:
    canary:
      steps:
        - setWeight: 20
        - pause: { duration: 10s }
        - setWeight: 50
        - pause: {} # Pause indéfinie (attente de validation manuelle)
  revisionHistoryLimit: 2
  selector:
    matchLabels:
      app: rollout-demo
  template:
    metadata:
      labels:
        app: rollout-demo
    spec:
      containers:
        - name: rollouts-demo
          image: argoproj/rollouts-demo:blue
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP

```

Applique la ressource :

```bash
kubectl apply -f rollout-demo.yaml

```

---

### 4. Simulation d'une mise à jour Canary et validation

1. **Lance le suivi en temps réel** dans un terminal :
```bash
kubectl argo rollouts get rollout rollout-demo -n guestbook-dev --watch

```


2. **Déclenche une mise à jour d'image** (passage du tag `blue` au tag `yellow`) depuis un second terminal :
```bash
kubectl argo rollouts set image rollout-demo rollouts-demo=argoproj/rollouts-demo:yellow -n guestbook-dev

```


3. **Observe le comportement** dans la fenêtre de suivi :
* 20 % du trafic (1 pod sur 5) passe en `yellow`, puis marque une pause de 10 secondes.
* Le déploiement monte automatiquement à 50 % puis s'arrête (étape `pause: {}`).


4. **Valide manuellement la livraison** pour passer à 100 % :
```bash
kubectl argo rollouts promote rollout-demo -n guestbook-dev

```


5. En cas de problème pendant le test, tu peux déclencher un **rollback instantané** :
```bash
kubectl argo rollouts undo rollout-demo -n guestbook-dev

```



---

Peux-tu valider l'installation du contrôleur et l'exécution du rollout Canary sur ton cluster avant d'attaquer la dernière étape, l'**Étape 6 : Séquencement et cycle de vie (Sync Waves & Hooks)** ?