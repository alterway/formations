# KUBERNETES : Environnement de Travail & Labs {-}

### Bienvenue dans votre Mission SRE / Platform !

![](images/kubernetes/kubernetes.png){height="120px"}

- **Contexte** : Vous intégrez l'équipe Platform Engineering d'une application Cloud Native en pleine croissance.
- **Votre mission** :
  - Déployer, interconnecter et sécuriser une architecture microservices.
  - Gérer la résilience (zéro downtime, pannes matérielles, autoscaling).
  - Industrialiser les déploiements avec GitOps (ArgoCD & Kustomize).
  - Résoudre des incidents réels en direct (CSI Kubernetes).

### Accès aux Labs Pratiques

- **Portail interactif des Labs** : <https://bit.ly/3XQHbUk>
- **Plateformes supportées** : Killercoda, vcluster, k3d, Kind ou cluster dédié.

![](images/kubernetes/cl-1.jpeg){height="380px"}

### Votre Boîte à Outils du Quotidien

- `kubectl` : Le CLI officiel indispensable.
- `k9s` : Interface TUI ultra-rapide pour explorer et déboguer le cluster en temps réel.
- `helm` & `kustomize` : Pour packager et spécialiser les manifestes YAML.
- `kubectx` / `kubens` : Pour switcher de cluster et de namespace en 1 seconde.

```
# Alias incontournable pour les pros :
alias k=kubectl
complete -o default -F __start_kubectl k
```

### Méthode d'Apprentissage : « Think, Break & Fix »

1. **Comprendre le flux interne** : Ne pas juste copier du YAML, comprendre ce que le Control Plane exécute.
2. **Pratiquer par le défi** : Chaque module comporte des mini-défis et pièges réels de production.
3. **Investigation méthodique** : Observer les événements, inspecter les statuts et auditer les logs.

