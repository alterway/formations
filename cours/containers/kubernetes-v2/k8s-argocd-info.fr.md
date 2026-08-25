# Introduction à Argo CD

### Qu'est-ce qu'Argo CD ?

- **Outil de déploiement continu (CD) pour Kubernetes**:
  - Argo CD est un outil open-source conçu pour automatiser le déploiement d'applications sur des clusters Kubernetes. Il utilise le paradigme GitOps, où Git est la source unique de vérité pour les déclarations d'état des applications.

- **Gestion déclarative des configurations**:
  - Argo CD utilise des fichiers de configuration déclaratifs (YAML ou JSON) pour définir l'état souhaité des applications. Ces configurations sont versionnées et stockées dans des référentiels Git.

- **Suivi et synchronisation des états des applications avec Git**:
  - Argo CD surveille en permanence les référentiels Git pour détecter les modifications et synchronise automatiquement l'état actuel du cluster Kubernetes avec l'état souhaité défini dans Git.

### Pourquoi utiliser Argo CD ?

- **Automatisation des déploiements**:
  - Argo CD simplifie et automatise le processus de déploiement, réduisant ainsi les risques d'erreurs humaines et augmentant la rapidité des déploiements.

- **Visibilité et traçabilité des changements**:
  - En utilisant Git comme source de vérité, toutes les modifications apportées aux configurations des applications sont traçables et réversibles. Cela améliore la transparence et facilite le suivi des changements au fil du temps.

- **Intégration facile avec des pipelines CI/CD existants**:
  - Argo CD peut être facilement intégré avec des outils CI/CD existants comme Jenkins, GitHub Actions, GitLab CI, etc., offrant une solution complète pour le cycle de vie des applications.

### Cas d'utilisation

- **Déploiement d'applications multi-environnement**:
  - Argo CD est idéal pour gérer des déploiements dans plusieurs environnements (développement, test, production) en utilisant des branches ou des répertoires différents dans le référentiel Git.

- **Gestion des configurations complexes**:
  - Il permet de gérer des configurations d'applications complexes, y compris des applications Helm, des kustomizations, et d'autres types de manifestes Kubernetes.

- **Support pour les mises à jour fréquentes**:
  - Pour les équipes qui déploient fréquemment des mises à jour, Argo CD offre une solution robuste pour synchroniser rapidement et efficacement les changements.



### Architecture d'Argo CD : Composants principaux

- **API Server**:
  - Le point d'entrée principal pour toutes les opérations Argo CD. Il expose une API RESTful utilisée par l'interface utilisateur web, la ligne de commande (CLI) et d'autres intégrations.
  
- **Repository Server**:
  - Ce composant est responsable de la gestion des référentiels Git. Il effectue des opérations Git pour récupérer les configurations des applications et les met à disposition des autres composants.

- **Controller**:
  - Le contrôleur Argo CD surveille en permanence l'état des applications et des clusters Kubernetes. Il compare l'état actuel avec l'état souhaité défini dans les configurations Git et effectue des actions de synchronisation pour aligner les deux.

- **Application Controller**:
  - Spécifiquement responsable de la gestion des applications individuelles. Il gère la synchronisation, le suivi des événements, et l'application des stratégies de déploiement.

- **User Interface (UI)**:
  - Une interface web intuitive pour visualiser et gérer les applications déployées. Elle permet aux utilisateurs de voir l'état des applications, de déclencher des synchronisations manuelles, et de configurer des projets.

### Fonctionnement et flux de travail

1. **Déclaration dans Git**:
    - Les configurations des applications Kubernetes sont définies de manière déclarative dans des fichiers YAML ou JSON et sont versionnées dans des référentiels Git.

2. **Surveillance par Argo CD**:
    - Argo CD surveille en permanence les référentiels Git pour détecter les changements. Lorsqu'une modification est détectée, elle est récupérée par le Repository Server.

3. **Comparaison d'état**:
    - Le Controller compare l'état actuel du cluster Kubernetes avec l'état souhaité défini dans les fichiers de configuration.

4. **Synchronisation**:
    - Si une divergence est détectée, le Controller synchronise l'état actuel du cluster avec l'état souhaité. Cela peut inclure des actions comme créer, mettre à jour ou supprimer des ressources Kubernetes.

5. **Gestion et visualisation**:
    - Les utilisateurs peuvent gérer et visualiser l'état des applications via l'interface utilisateur web ou la CLI. Ils peuvent également configurer des politiques de synchronisation automatique ou manuelle.

### Intégration avec Kubernetes

- **Cluster Kubernetes**:
  - Argo CD s'intègre directement avec un ou plusieurs clusters Kubernetes. Il peut déployer des applications sur différents clusters en fonction des configurations définies.

- **RBAC (Role-Based Access Control)**:
  - Argo CD utilise le RBAC de Kubernetes pour contrôler l'accès aux ressources et aux opérations. Les utilisateurs peuvent se voir attribuer différents rôles et permissions.

- **CRDs (Custom Resource Definitions)**:
  - Argo CD utilise des CRDs pour gérer les applications et les projets. Cela permet une intégration native et transparente avec l'écosystème Kubernetes.

### Diagramme de l'architecture



### Concepts de base : **Applications**



Définition:

- Une application dans Argo CD représente une collection de ressources Kubernetes (pods, services, configurations, etc.) définies de manière déclarative dans un référentiel Git.

- Composants d'une Application:

    - Source: Le référentiel Git et le chemin où se trouvent les configurations de l'application.
        - Repository URL: L'URL du référentiel Git.
        - Path: Le chemin dans le repository où les fichiers de configuration de l'application se trouvent.
        - Target Revision: La branche, tag ou commit spécifique à partir duquel synchroniser les configurations.
    - Destination: Le cluster Kubernetes et l'espace de noms où l'application sera déployée.
        - Cluster URL: L'URL du serveur API Kubernetes du cluster cible.
        - Namespace: L'espace de noms Kubernetes où les ressources de l'application seront déployées.
    - Sync Policy: La politique de synchronisation qui détermine comment et quand les changements sont appliqués.
        - Manual: La synchronisation doit être déclenchée manuellement.
        - Automatic: La synchronisation se produit automatiquement lorsque des changements sont détectés dans le référentiel Git.
  

### Création d'une Application:

Via CLI: Utilisez la commande argocd app create pour créer une application.

```bash
argocd app create my-app \
  --repo https://github.com/your-repo/your-app.git \
  --path k8s-manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default
```

Via l'Interface Utilisateur: Utilisez l'UI web d'Argo CD pour configurer et créer une application.


Via un manifeste

```yaml
--
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cilium
  namespace: argoproj
  labels:
    deploymentStrategy: helm
spec:
  project: default
  source:
    path: argocd/apps/cilium
    repoURL: git@github.com:NIXKnight/ArgoCD-Demo.git
    targetRevision: master
  destination:
    namespace: kube-system
    server: https://kubernetes.default.svc
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```


### Concepts de base : **Projets**



Définition:

    - Un projet dans Argo CD est une manière de regrouper plusieurs applications sous une même entité pour gérer les permissions et les politiques de manière centralisée.

    - Utilisation:

        - RBAC (Role-Based Access Control): Les projets permettent de définir des règles de contrôle d'accès basées sur les rôles pour les applications incluses dans le projet.
        - Restrictions: Les projets peuvent imposer des restrictions sur les référentiels Git autorisés, les clusters, et les espaces de noms où les applications peuvent être déployées.
        - Source Repositories: Liste des référentiels Git autorisés.
        - Destinations: Clusters et namespaces autorisés pour le déploiement.
        - Cluster Resource Whitelist: Liste des types de ressources de cluster que les applications peuvent gérer.

### Création d'un Projet

Via CLI: Utilisez la commande `argocd proj create` pour créer un projet 

```bash 
argocd proj create my-project \
  --description "Project for my applications" \
  --src-repos https://github.com/your-repo/* \
  --dest-clusters https://kubernetes.default.svc \
  --dest-namespaces default,staging,production
```

Via l'Interface Utilisateur: Utilisez l'UI web d'Argo CD pour configurer et créer un projet.

Via un manifeste

```yaml 
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: sobki
  namespace: argocd
spec:
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  description: sobki
  destinations:
  - name: '*'
    namespace: '*'
    server: '*'
  sourceRepos:
  - '*'
```

### Concepts de base : Repositories Git


Définition:

-  Les référentiels Git contiennent les configurations déclaratives des applications. Argo CD les utilise comme source de vérité pour l'état des applications.

Configuration:

  - Ajouter un Référentiel Git: Vous pouvez ajouter des référentiels Git à Argo CD via l'interface utilisateur web ou la CLI (argocd repo add).
      - Public Repositories: Les référentiels publics peuvent être ajoutés sans authentification.
      - Private Repositories: Les référentiels privés nécessitent une authentification, que ce soit via SSH, HTTPS avec utilisateur/mot de passe, ou tokens d'accès personnels.

```bash
argocd repo add https://github.com/your-repo/your-app.git \
  --username <username> \
  --password <password>
```

Les repos sont stockés sous forme de `secrets` dans le namespace `argocd`.

Il est théoriquement possible de créer un secret ayant pour nom `repo-xxxxxxxxxx` 
xxxxxxxxxx étant un nombre aléatoire.

Structure :

```
apiVersion: v1
data:
  project: ZGVmYXVsdA==
  type: Z2l0
  url: aHR0cHM6Ly9naXRodWIuY29tL2hlcnZlbGVjbGVyYy9hcmdvY2QtdmF1bHQtcGx1Z2luLWRlbW8uZ2l0
kind: Secret
metadata:
  annotations:
    managed-by: argocd.argoproj.io
  labels:
    argocd.argoproj.io/secret-type: repository
  name: repo-4073937955
  namespace: argocd
type: Opaque
```



### Concepts de base :  Synchronisation et auto-sync

Synchronisation:

    - Le processus de comparaison de l'état actuel des ressources Kubernetes avec l'état souhaité défini dans les fichiers de configuration Git.
  
    - Actions de Synchronisation: Si des différences sont détectées, Argo CD peut créer, mettre à jour, ou supprimer des ressources pour aligner l'état actuel du cluster avec l'état souhaité.
Sync Status: Indique si l'application est en
