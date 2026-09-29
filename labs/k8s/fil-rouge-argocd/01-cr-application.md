## Étape 2 : Gestion des applications (CRD `Application`)

La Custom Resource Definition (CRD) `Application` est le cœur d'Argo CD. Elle fait le pont entre un dépôt Git (la source de vérité) et un cluster Kubernetes (la cible).

### 1. Structure de la CRD `Application`

Créons un manifeste déclaratif `guestbook-app.yaml` déployant une application Kustomize d'exemple :

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
  # Optionnel : supprime les ressources Kubernetes associées si l'Application est supprimée dans Argo CD
  finalizers:
    # Utiliser /foreground ou /background ajoute le slash requis par K8s
    - resources-finalizer.argocd.argoproj.io/foreground
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD # Branche, tag ou commit SHA
    path: guestbook      # Répertoire contenant les manifestes (ou Chart.yaml / kustomization.yaml)
  destination:
    server: https://kubernetes.default.svc # Cluster local où Argo CD est installé
    namespace: guestbook-dev
  syncPolicy:
    automated:
      prune: true     # Supprime les ressources K8s absentes de Git
      selfHeal: true  # Annule et corrige les modifications manuelles faites sur le cluster (anti-drift)
    syncOptions:
      - CreateNamespace=true # Crée automatiquement le namespace cible s'il n'existe pas

```

### 2. Mécanismes de synchronisation et auto-réparation

* **`automated.prune`** : Si tu supprimes un fichier YAML de ton dépôt Git, Argo CD détruira automatiquement la ressource correspondante dans le cluster.
* **`automated.selfHeal`** : Si un administrateur modifie une ressource directement via `kubectl edit` ou `kubectl patch`, le contrôleur réapplique immédiatement la configuration contenue dans Git pour éliminer la dérive (*drift*).
* **Sync Options (`CreateNamespace=true`)** : Permet de déléguer la création de namespaces directement à Argo CD sans devoir les déclarer au préalable dans le cluster.

### 3. Application du manifeste

Déploie cette application en appliquant le fichier YAML sur ton cluster :

```bash
kubectl apply -f guestbook-app.yaml

```

Vérifie l'état de l'application via la CLI Argo CD ou l'interface UI (`[https://argocd-hleclerc.apps.caas.fr](https://argocd-hleclerc.apps.caas.fr)`) :

```bash
# Vérifier l'état de l'application
argocd app get guestbook

# Forcer une synchronisation manuelle si nécessaire
argocd app sync guestbook

```

---