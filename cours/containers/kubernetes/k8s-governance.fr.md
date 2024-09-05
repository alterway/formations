
# KUBERNETES : Projet, Gouvernance et Communauté {-}


###  

![](images/kubernetes/kubernetes.png){height="100px"}

- Initialement développé par Google (Borg), devenu open source en 2014
- 1.0 le 10 Juillet 2015
- Adapté à tout type d'environnement
- Devenu populaire en très peu de temps
- Premier projet de la CNCF

![](images/kubernetes/story-of-kubernetes.png){height="300px"}



### CNCF

*The Foundation’s mission is to create and drive the adoption of a new computing paradigm that is optimized for modern distributed systems environments capable of scaling to tens of thousands of self healing multi-tenant nodes.*

![](images/kubernetes/cncf.png){height="100px"}


### CNCF : Pré-requis

1. Alignement avec les Objectifs de la CNCF
   
  - Technologies Cloud Natives: Votre projet doit être étroitement lié aux technologies cloud natives, telles que les conteneurs, les orchestrateurs de conteneurs (Kubernetes), les services de réseau, les systèmes de stockage distribués, et les outils de gestion du cycle de vie des applications cloud natives.

  - Open Source: Le projet doit être open source sous une licence approuvée par la CNCF (comme Apache 2.0 ou MIT).

  - Communauté Active: Il est essentiel de démontrer l'existence d'une communauté active autour du projet, avec des contributions régulières de développeurs et des utilisateurs.

2. Maturation du Projet
   
  - Code de Qualité: Le code source doit être bien structuré, documenté et suivre les meilleures pratiques de développement.

  - Tests Unitaires et d'Intégration: Une couverture de tests solide est nécessaire pour garantir la qualité et la stabilité du projet.

  - Documentation Complète: Une documentation claire et complète est indispensable pour permettre aux autres développeurs de comprendre et d'utiliser le projet.



### CNCF : Les rôles


- Hébergement de Projets Open Source:

    - La CNCF héberge un grand nombre de projets open source populaires, tels que Kubernetes, Prometheus, Envoy, et bien d'autres. Ces projets sont au cœur de l'infrastructure cloud native moderne.
    - Elle fournit un cadre de gouvernance et un environnement de collaboration pour ces projets.

- Définition de Standards:

    - La CNCF travaille à la définition de standards et de meilleures pratiques pour les technologies cloud natives.
    - Elle favorise l'interopérabilité entre les différents projets et outils.

- Promotion de l'Écosystème:

    - La CNCF organise des événements, des conférences et des meetups pour promouvoir les technologies cloud natives et rassembler la communauté.
    - Elle favorise l'adoption de ces technologies par les entreprises et les développeurs.

- Incubation de Nouveaux Projets:

    - La CNCF offre un programme d'incubation pour les nouveaux projets qui répondent à ses critères.
    - Elle aide ces projets à se développer et à atteindre la maturité nécessaire pour rejoindre la CNCF en tant que projet hébergé.

- Collaboration avec l'Industrie:

    - La CNCF travaille en étroite collaboration avec les principaux acteurs de l'industrie du cloud, tels que les fournisseurs de cloud public, les entreprises technologiques et les universités.

- Elle contribue à façonner l'avenir du cloud computing.


### OCI

- Créé sous la Linux Fondation
- But : Créer un standard Open Source concernant la manière de "runner" et le format des conteneurs et images
- Non lié à des produits
- Non lié à des COE
- runC a été donné par Docker à l'OCI comme implémentions de base

![](images/docker/oci.png){height="100px"}

### Kubernetes : Projet

- Docs : <https://kubernetes.io/docs/>
- Slack : <http://slack.k8s.io/>
- Discuss : <https://discuss.kubernetes.io>
- Stack Overflow : <https://stackoverflow.com/questions/tagged/kubernetes>
- Serverfault <https://stackoverflow.com/questions/tagged/kubernetes>

### Kubernetes : Projet (suite)

- Hébergé sur Github : <https://github.com/kubernetes/kubernetes> :
    - Issues : <https://github.com/kubernetes/kubernetes/issues>
    - Pull Requests <https://github.com/kubernetes/kubernetes/pulls>
    - Releases : <https://github.com/kubernetes/kubernetes/releases>
- Projets en incubation :
    - <https://github.com/kubernetes-sigs/>

### Kubernetes : Cycle de développement 1/3

- Chaque _release_ a son propre planning, pour exemple : <https://github.com/kubernetes/sig-release/tree/master/releases/release-1.30#timeline>

- Fréquence des releases :
    - Kubernetes suit généralement un cycle de release trimestriel
    - Il y a habituellement 3 releases majeures par an


- Structure de versionnage :

    - Format : vX.Y.Z (par exemple, v1.26.0)
    - X : Version majeure (rarement changée)
    - Y : Version mineure (mise à jour trimestrielle)
    - Z : Version de patch (mises à jour de sécurité et corrections de bugs)


- Phases du cycle de release :

    - Planification
    - Développement
    - Code Freeze
    - Tests et stabilisation
    - Release

### Kubernetes : Cycle de développement 2/3

- Durée du cycle :

    - Environ 12 à 14 semaines pour une release complète


- Support des versions :

    - Les 3 dernières versions mineures sont généralement supportées
    - Chaque version est supportée pendant environ 9 mois


- Types de fonctionnalités :

    - Alpha : Expérimentales, peuvent être instables
    - Beta : Plus stables, mais pas garanties pour la production
    - Stable : Prêtes pour la production


### Kubernetes : Cycle de développement 3/3

- Processus communautaire :

    - Développement piloté par la communauté open-source
    - Implication de divers Special Interest Groups (SIGs)


- Compatibilité :

    - Effort pour maintenir une compatibilité ascendante entre les versions

- Documentation :

    - Mise à jour avec chaque nouvelle release


- Communication :

    - Annonces anticipées des dates de release et des changements majeurs
    - Publication de notes de release détaillée

### Kubernetes : Communauté

- Contributor and community guide : <https://github.com/kubernetes/community/blob/master/README.md#kubernetes-community>
- Décomposée en [Special Interest Groups] : <https://github.com/kubernetes/community/blob/master/sig-list.md>
  
- Les SIG (Special Interest Groups) sont une partie essentielle de la structure organisationnelle de la communauté Kubernetes. Ils jouent un rôle crucial dans le développement et la maintenance de différents aspects de Kubernetes. 


| SIG | Description | SIG | Description |
|-----|-------------|-----|-------------|
| API Machinery | Frameworks extensibles pour les API | Apps | Déploiements et charges de travail |
| Architecture | Architecture globale et conception du projet | Auth | Authentification et autorisation |
| Autoscaling | Mise à l'échelle automatique des clusters et workloads | CLI | kubectl et outils en ligne de commande |
| Cloud Provider | Intégration avec les fournisseurs de cloud | Cluster Lifecycle | Outils pour la gestion du cycle de vie des clusters |
| Contributor Experience | Amélioration de l'expérience des contributeurs | Docs | Documentation et site web de Kubernetes |
| Instrumentation | Métriques, logging, et monitoring | Multicluster | Gestion de multiples clusters |
| Network | Réseautage dans Kubernetes | Node | Composants au niveau du nœud |
| Release | Coordination des releases | Scalability | Performance et scalabilité |
| Scheduling | Planification des pods | Security | Sécurité du projet |
| Storage | Stockage et volumes | Testing | Tests et infrastructure de test |
| UI | Interface utilisateur et tableaux de bord | Windows | Support de Windows dans Kubernetes |



### Kubernetes : KubeCon

La CNCF organise 3 KubeCon par an :

  - Amérique du Nord (San Diego, Seattle, etc)
  - Europe (Berlin, Barcelone, Amsterdam etc)
  - Chine

Thèmes abordés :

  - Les Kubecon couvrent un large éventail de sujets liés à Kubernetes, tels que :
  - Les dernières fonctionnalités et évolutions de Kubernetes
  - Les meilleures pratiques pour déployer et gérer des applications conteneurisées
  - L'intégration de Kubernetes avec d'autres technologies cloud-native (Istio, Helm, etc.)
  - Les cas d'utilisation de Kubernetes dans différents secteurs (finance, retail, etc.)
  - Les défis et les solutions liés à la sécurité, la performance et la scalabilité des clusters Kubernetes


Pour plus d'informations, Consulter le site officiel de la Cloud Native Computing Foundation (CNCF), l'organisation à l'origine de Kubernetes : <https://www.cncf.io/>