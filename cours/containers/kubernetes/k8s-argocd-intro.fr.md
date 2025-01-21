# Introduction à ArgoCD

### Qu'est-ce qu'ArgoCD ?

ArgoCD est un outil de déploiement continu (CD) déclaratif pour Kubernetes.
- Conçu pour implémenter le GitOps
- Open source et partie de la CNCF
- Permet de synchroniser l'état souhaité (Git) avec l'état réel (Kubernetes)


### ArgoCD : Avantages Clés
- **GitOps natif**: Votre code Git devient la source unique de vérité
- **Automatisation**: Déploiements automatiques lors des changements dans Git
- **Visibilité**: Interface utilisateur intuitive pour surveiller les déploiements
- **Sécurité**: Gestion fine des accès et audit complet des changements

## ArgoCD: Architecture

```
                    ┌─────────────┐
                    │             │
                    │    Git      │
                    │             │
                    └──────┬──────┘
                           │
                           ▼
┌──────────────┐   ┌──────────────┐   ┌─────────────┐
│   ArgoCD     │   │   ArgoCD     │   │             │
│     API      │◄──┤  Controller  │──►│  Kubernetes │
│    Server    │   │              │   │   Cluster   │
└──────────────┘   └──────────────┘   └─────────────┘
```

### ArgoCD : Concepts Fondamentaux


![argocd](images/kubernetes/argocd.png)



### 1. Applications
- Groupe de ressources Kubernetes à déployer ensemble
- Définies de manière déclarative
- Peuvent être liées à différentes sources (Git, Helm)

### 2. Projets
- Regroupement logique d'applications
- Permet de définir des restrictions et des permissions
- Isolation des ressources par équipe/environnement

### 3. Synchronisation
- Automatique ou manuelle
- Détection des dérives de configuration
- Rollback automatique possible

### Exemple de Configuration

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: mon-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/mon-org/mon-app.git
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: production
```

### Bonnes Pratiques

1. **Structure des Repositories**
   - Séparer le code applicatif des manifestes Kubernetes
   - Utiliser des branches pour les différents environnements

2. **Sécurité**
   - Implémenter RBAC strict
   - Utiliser des secrets externes
   - Activer SSO quand possible

3. **Monitoring**
   - Configurer des alertes sur les échecs de synchronisation
   - Surveiller les métriques ArgoCD
   - Mettre en place des notifications

### Pour Aller Plus Loin

- Documentation officielle : https://argo-cd.readthedocs.io/
- Projets complémentaires :
  - Argo Rollouts pour les déploiements avancés
  - Argo Events pour l'event-driven
  - Argo Workflows pour l'orchestration

   