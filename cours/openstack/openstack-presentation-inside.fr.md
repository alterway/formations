## Fonctionnement interne

### Architecture

![Vue détaillée des services](images/architecture-simple.jpg)

### Implémentation

-   Tout est développé en Python (Django pour la partie web)
-   Chaque projet est découpé en plusieurs services (exemple : API, scheduler, etc.)
-   Réutilisation de composants existants et de bibliothèques existantes
-   Utilisation des bibliothèques `oslo.*` (développées par et pour OpenStack) : logs, config, etc.
-   Utilisation de `rootwrap` pour appeler des programmes sous-jacents en root

### Implémentation - dépendances

-   Base de données : relationnelle SQL (MySQL/MariaDB)
-   Communication entre les services : AMQP (RabbitMQ)
-   Mise en cache : Memcached
-   Stockage distribué de configuration (à venir) : etcd

## Modèle de développement

### Statistiques (2017)

-   2344 développeurs
-   65823 changements (commits)

<https://www.openstack.org/assets/reports/OpenStack-AnnualReport2017.pdf>

### Développement du projet : en détails

-   Ouvert à tous (individuels et entreprises)
-   Cycle de développement de 6 mois
-   Chaque cycle débute par un Project Team Gathering (PTG)
-   Pendant chaque cycle a lieu un OpenStack Summit

### Les outils et la communication

-   Code : Git (GitHub est utilisé comme miroir)
-   Revue de code (peer review) : Gerrit
-   Intégration continue (CI: Continous Integration) : Zuul
-   Blueprints/spécifications et bugs :
    -    Launchpad
    -    StoryBoard
-   Communication : IRC et mailing-lists
-   Traduction : Zanata

### Développement du projet : en détails

![Workflow de changements dans OpenStack](images/openstack-dev-workflow-diagram.png)

### Cycle de développement : 6 mois

-   Le planning est publié, exemple : <https://releases.openstack.org/stein/schedule.html>
-   Milestone releases
-   Freezes : Feature, Requirements, String
-   RC releases
-   Stable releases
-   Cas particulier de certains composants : <https://releases.openstack.org/reference/release_models.html>

### Projets

-   Équipes projet (*Project Teams*) : <https://governance.openstack.org/reference/projects/index.html>
-   Chaque livrable est versionné indépendamment - *Semantic versioning*
-   <https://releases.openstack.org/>

### Qui contribue ?

-   *Active Technical Contributor* (ATC)
    -   Personne ayant au moins une contribution récente dans un projet OpenStack reconnu
    -   Droit de vote (TC et PTL)
-   *Core reviewer* : ATC ayant les droits pour valider les patchs dans un projet
-   *Project Team Lead* (PTL) : élu par les ATCs de chaque projet
-   Stackalytics fournit des statistiques sur les contributions <http://stackalytics.com/>

### Où trouver des informations sur le développement d’OpenStack

-   Comment contribuer
    -   <https://docs.openstack.org/project-team-guide/>
    -   <https://docs.openstack.org/infra/manual/>
-   Informations diverses, sur le wiki
    -   <https://wiki.openstack.org/>
-   Les blueprints et bugs sur Launchpad/StoryBoard
    -   <https://launchpad.net/openstack/>
    -   <https://storyboard.openstack.org/>
    -   <https://specs.openstack.org/>

### Où trouver des informations sur le développement d’OpenStack

-   Les patchs proposés et leurs reviews sont sur Gerrit
    -   <https://review.openstack.org/>
-   L’état de la CI (entre autres)
    -   <http://status.openstack.org/>
-   Le code (Git) et les tarballs sont disponibles
    -   <https://git.openstack.org/>
    -   <https://tarballs.openstack.org/>
-   IRC
    - Réseau Freenode
    - Logs discussions et infos réunions : <http://eavesdrop.openstack.org/>
-   Mailing-lists
    - <http://lists.openstack.org/>

### Upstream Training

-   Deux jours de formation
-   Apprendre à devenir contributeur à OpenStack
-   Les outils
-   Les processes
-   Travailler et collaborer de manière ouverte

### OpenStack Infra

-   Équipe projet en charge de l’infrastructure de développement d’OpenStack
-   Travaille comme les équipes de dev d’OpenStack et utilise les mêmes outils
-   Résultat : Infrastructure as code **open source** <https://opensourceinfra.org/>
-   Utilise du cloud (hybride)
-   Développe certains outils
    - Zuul
    - yaml2ical

### OpenStack Summit

-   Tous les 6 mois en milieu de cycle de développpement
-   Aux USA jusqu’en 2013, aujourd'hui alternance Amérique de Nord et Asie/Europe
-   Quelques dizaines au début à des milliers de participants aujourd’hui
-   En parallèle : conférence (utilisateurs, décideurs) et Forum (développeurs/opérateurs, remplace une partie du précédent Design Summit)
-   Détermine le nom de la prochaine release : lieu/ville à proximité du Summit

### Exemple du Summit d’avril 2013 à Portland

![Photo : Adrien Cunin](images/photo-summit.jpg)

### Exemple du Summit d’octobre 2015 à Tokyo

![Photo : Elizabeth K. Joseph, CC BY 2.0, Flickr/pleia2](images/photo-summit1.jpg)

### Exemple du Summit d’octobre 2015 à Tokyo

![Photo : Elizabeth K. Joseph, CC BY 2.0, Flickr/pleia2](images/photo-summit2.jpg)

### Exemple du Summit d’octobre 2015 à Tokyo

![Photo : Elizabeth K. Joseph, CC BY 2.0, Flickr/pleia2](images/photo-summit3.jpg)

### Exemple du Summit d’octobre 2015 à Tokyo

![Photo : Elizabeth K. Joseph, CC BY 2.0, Flickr/pleia2](images/photo-summit4.jpg)

### Project Team Gathering (PTG)

-   Depuis 2017
-   Au début de chaque cycle
-   Remplace une partie du précédent Design Summit
-   Dédié aux développeurs

### Traduction

-   Équipe officielle *i18n*
-   Seules certaines parties sont traduites, comme Horizon
-   La traduction française est aujourd’hui une des plus avancées
-   Utilisation d'une plateforme web basée Zanata : <https://translate.openstack.org/>

## DevStack : faire tourner rapidement un OpenStack

### Utilité de DevStack

-   Déployer rapidement un OpenStack
-   Utilisé par les développeurs pour tester leurs changements
-   Utilisé pour faire des démonstrations
-   Utilisé pour tester les APIs sans se préoccuper du déploiement
-   Ne doit PAS être utilisé pour de la production

### Fonctionnement de DevStack

-   Support d'Ubuntu 16.04/17.04, Fedora 24/25, CentOS/RHEL 7, Debian, OpenSUSE
-   Un script shell qui fait tout le travail : stack.sh
-   Un fichier de configuration : local.conf
-   Installe toutes les dépendances nécessaires (paquets)
-   Clone les dépôts git (branche master par défaut)
-   Lance tous les composants

### Configuration : local.conf

Exemple

    [[local|localrc]]
    ADMIN_PASSWORD=secrete
    DATABASE_PASSWORD=$ADMIN_PASSWORD
    RABBIT_PASSWORD=$ADMIN_PASSWORD
    SERVICE_PASSWORD=$ADMIN_PASSWORD
    SERVICE_TOKEN=a682f596-76f3-11e3-b3b2-e716f9080d50
    #FIXED_RANGE=172.31.1.0/24
    #FLOATING_RANGE=192.168.20.0/25
    #HOST_IP=10.3.4.5

### Conseils d’utilisation

-   DevStack installe beaucoup de choses sur la machine
-   Il est recommandé de travailler dans une VM
-   Pour tester tous les composants OpenStack dans de bonnes conditions, plusieurs Go de RAM sont nécessaires
-   L’utilisation de Vagrant est conseillée

