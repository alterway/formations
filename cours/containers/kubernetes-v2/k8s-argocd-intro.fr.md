# KUBERNETES : Industrialisation GitOps avec ArgoCD {-}

### Qu'est-ce que le GitOps ?

```
          APPROCHE CI CLASSIQUE                     APPROCHE GITOPS (ArgoCD)
  [ Runner CI / GitHub Actions ]              [ Git Repository (Source of Truth) ]
                │ (Push)                                       │
                ▼ (Droits admin requis !)                      ▼ (Pull & Reconcile)
       [ Cluster Kubernetes ]                       [ ArgoCD dans le Cluster ]
  (Sécurité faible : tokens exposés)            (Sécurité maximale : 0 port ouvert !)
```

![](images/kubernetes/argocd.png){height="140px"}

- **Les 4 Principes OpenGitOps** :
  1. **Déclaratif** : Tout le système est décrit en YAML.
  2. **Versionné & Immuable** : Git est l'unique source de vérité (`Single Source of Truth`).
  3. **Tiré Automatiquement** : Le cluster tire les changements depuis Git (Pull model).
  4. **Réconcilié en Continu** : ArgoCD répare automatiquement toute dérive manuelle (`Self-Healing`).

### 1. L'Objet `Application` d'ArgoCD

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bookstore-production
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/mon-orga/k8s-manifests.git
    targetRevision: main
    path: overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true       # Supprime du cluster les objets supprimés dans Git !
      selfHeal: true    # Annule et réécrit toute modification manuelle directe faite via kubectl !
```

### 2. Le Tableau de Bord & les Statuts ArgoCD

```
    SYNC STATUS                              HEALTH STATUS
  ┌───────────────┐                        ┌───────────────┐
  │ Synced        │ (Cluster == Git)       │ Healthy       │ (Tous les pods sont Ready)
  │ OutOfSync     │ (Git a changé)         │ Progressing   │ (Rolling update en cours)
  │ Unknown       │ (Erreur de parsing)    │ Degraded      │ (CrashLoopBackOff / Erreur)
  └───────────────┘                        └───────────────┘
```

- **Drift Correction (Self-Healing)** : Si un développeur supprime un Pod ou modifie un Service avec `kubectl edit` en production, ArgoCD détecte l'écart en quelques secondes et rétablit immédiatement l'état déclaré dans Git !

### 3. Gestion Multi-Clusters : `ApplicationSet`

Pour gérer 100 applications réparties sur 10 clusters (Dev, Staging, Prod, Multi-Cloud) sans dupliquer 1000 lignes de YAML :

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: all-microservices
  namespace: argocd
spec:
  generators:
  - git:
      repoURL: https://github.com/mon-orga/k8s-manifests.git
      revision: main
      directories:
      - path: services/*
  template:
    metadata:
      name: "{{path.basename}}"
    spec:
      project: default
      source:
        repoURL: https://github.com/mon-orga/k8s-manifests.git
        targetRevision: main
        path: "{{path}}"
      destination:
        server: https://kubernetes.default.svc
        namespace: apps
```

### Mini-Défi : L'Effet du Self-Healing

**Scénario de test** : Vous avez configuré une Application ArgoCD avec `syncPolicy.automated.selfHeal: true`.
Un administrateur supprime accidentellement un Deployment avec `kubectl delete deployment bookstore-api`.

Que se passe-t-il dans les 10 secondes qui suivent ?

### Mini-Défi : L'Effet du Self-Healing

**Scénario de test** : Vous avez configuré une Application ArgoCD avec `syncPolicy.automated.selfHeal: true`.
Un administrateur supprime accidentellement un Deployment avec `kubectl delete deployment bookstore-api`.

Que se passe-t-il dans les 10 secondes qui suivent ?

(Réponse : ArgoCD détecte que le Deployment manque dans le cluster par rapport à la branche `main` de Git, et le recrée instantanément à l'identique !).

