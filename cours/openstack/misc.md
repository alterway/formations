# Stockage : block, objet, SDS

### Stockage block

-   Accès à des raw devices type */dev/vdb*
-   Possibilité d’utiliser n’importe quel système de fichiers
-   Compatible avec toutes les applications legacy

### Stockage objet

-   Pousser et retirer des objets dans un container/bucket
-   Pas de hiérarchie des données, pas de système de fichiers
-   Accès par les APIs
-   L’application doit être conçue pour tirer partie du stockage objet

### Stockage objet : schéma

![image](images/stockage-objet.png)

### SDS : Software Defined Storage

-   Utilisation de commodity hardware
-   Pas de RAID matériel
-   Le logiciel est responsable de garantir les données
-   Les pannes matérielles sont prises en compte et gérées

### Deux solutions : OpenStack Swift et Ceph

-   Swift fait partie du projet OpenStack et fournit du stockage objet
-   Ceph fournit du stockage objet, block et FS
-   Les deux sont implémentés en SDS
-   Théorème CAP : on en choisit deux

### Théorème CAP

![image](images/cap.jpg)

### Swift

-   Swift est un projet OpenStack
-   Le projet est né chez Rackspace avant la création d’OpenStack
-   Swift est en production chez Rackspace depuis lors
-   C’est le composant le plus mature d’OpenStack

### Ceph

-   Projet totalement parallèle à OpenStack
-   Supporté par une entreprise (Inktank) récemment rachetée par Red Hat
-   Fournit d’abord du stockage objet
-   L’accès aux données se fait via RADOS :
    -   Accès direct depuis une application avec librados
    -   Accès via une API REST grâce à radosgw
-   La couche RBD permet d’accéder aux données en mode block (volumes)
-   CephFS permet un accès par un système de fichiers POSIX

### Le nouveau modèle “big tent”

-   Évolutions presque totalement implémentées
-   Objectif : résoudre les limitations du modèle incubation/intégré
-   Inclusion a priori de l’ensemble de l’écosystème OpenStack
-   *Programs* $\rightarrow$ *Project Teams*
-   Disparation des statuts en incubation et intégré
-   Utilisation de tags factuels et objectifs

### Traduction

-   La question de la traduction est dorénavant prise en compte (officialisation de l’équipe *i18n*)
-   Seules certaines parties sont traduites, comme Horizon
-   La traduction française est aujourd’hui une des plus avancées
-   Utilisation de la plateforme Transifex (en cours de migration vers l’outil libre Zanata)

### Stackforge

-   Forge pour les nouveaux projets en lien avec OpenStack
-   Ils bénéficient de l’infrastructure du projet OpenStack, mais la séparation reste claire
-   Les projets démarrent dans Stackforge et peuvent ensuite rejoindre le projet OpenStack
-   En train de disparaitre au profit du modèle “big tent”

### Implémentation

-   Chaque sous-projet est découpé en plusieurs services
-   Communication entre les services : AMQP (RabbitMQ)
-   Base de données : relationnelle SQL (MySQL/MariaDB)
-   Réseau : OpenVSwitch
-   En général : réutilisation de composants existants
-   Tout est développé en Python (Django pour la partie web)
-   APIs supportées : OpenStack et équivalent Amazon
-   Multi tenancy

### Architecture

![image](images/architecture-simple.jpg)

### Cycle de développement : 6 mois

-   Le planning est publié, exemple : <https://wiki.openstack.org/wiki/Mitaka_Release_Schedule>
-   Milestone releases
-   Freezes : FeatureProposal, Feature, String
-   RC releases
-   Stable releases
-   Ce modèle de cycle de développement a évolué depuis le début du projet
-   Cas particulier de Swift et de plus en plus de composants
-   Depuis Liberty, chaque composant gère son propre versionnement

### Versionnement depuis Liberty

-   *Semantic versioning*
-   Chaque projet est indépendant
-   Dans le cadre du cycle de release néanmoins
-   <http://docs.openstack.org/releases/>

### Où trouver des informations sur le développement d’OpenStack

-   Principalement sur le wiki : <https://wiki.openstack.org>
-   Les blueprints et bugs sur Launchpad/StoryBoard : <https://launchpad.net/openstack>, <https://storyboard.openstack.org>, <http://specs.openstack.org/>
-   Les patchs proposés et leurs reviews sont sur Gerrit : <https://review.openstack.org>
-   L’état de la CI (entre autres) : <http://status.openstack.org>
-   Le code est disponible dans Git : <https://git.openstack.org>
-   Les sources (tarballs) sont disponibles : <http://tarballs.openstack.org/>

### Qui contribue ?

-   *Active Technical Contributor*
-   ATC : personne ayant au moins une contribution récente dans un projet OpenStack reconnu
-   Les ATC sont invités aux summits et ont le droit de vote
-   *Core reviewer* : ATC ayant les droits pour valider les patchs dans un projet
-   *Project Team Lead* (PTL) : élu par les ATCs de chaque projet
-   Stackalytics fournit des statistiques sur les contributions
<http://stackalytics.com/>

### OpenStack Summit

-   Aux USA jusqu’en 2013
-   Aujourd’hui : alternance Amérique de Nord et Asie/Europe
-   Quelques centaines au début à 4500 participants aujourd’hui
-   En parallèle : conférence (utilisateurs, décideurs) et Design Summit (développeurs)
-   Détermine le nom de la release : lieu/ville à proximité du Summit
-   *Upstream Training*

### Exemple du Summit d’avril 2013 à Portland

![image](images/photo-summit.jpg)

### Exemple du Summit d’octobre 2015 à Tokyo

![image](images/photo-summit1.jpg) Photo : Elizabeth K. Joseph, CC BY

2.0, Flickr/pleia2

### Exemple du Summit d’octobre 2015 à Tokyo

![image](images/photo-summit2.jpg) Photo : Elizabeth K. Joseph, CC BY
2.0, Flickr/pleia2

### Exemple du Summit d’octobre 2015 à Tokyo

![image](images/photo-summit3.jpg) Photo : Elizabeth K. Joseph, CC BY
2.0, Flickr/pleia2

### Exemple du Summit d’octobre 2015 à Tokyo

![image](images/photo-summit4.jpg) Photo : Elizabeth K. Joseph, CC BY
2.0, Flickr/pleia2

### Développement du projet : en détails

-   Ouvert à tous (individuels et entreprises)
-   Cycle de développement de 6 mois débuté par un (design) summit
-   Outils : Launchpad $\rightarrow$ Storyboard (blueprints, bugs) + Git + GitHub (code)
-   Sur chaque patch proposé :
    -   Revue de code (peer review) : Gerrit, <https://review.openstack.org>
    -   Intégration continue (continous integration) : Jenkins, Zuul, etc., <http://zuul.openstack.org/>
-   Développement hyper actif : 17000 commits dans Icehouse (+25%)
-   Fin 2012, création d’une entité indépendante de gouvernance : la fondation OpenStack
### OpenStack Infra
-   Équipe projet en charge de l’infrastructure de développement d’OpenStack
-   Travaille comme les équipes de dev d’OpenStack et utilise les mêmes outils
-   Résultat : une infrastructure entièrement open source et développée comme tel

# Orchestrer les ressources de son IaaS

### Pourquoi orchestrer

-   Définir tout une infrastructure dans un seul fichier texte
-   Être en capacité d’instancier une infrastructure entière en un appel API
-   Autoscaling
    -   Adapter ses ressources en fonction de ses besoins en temps réel
    -   Fonctionnalité incluse dans le composant d’orchestration d’OpenStack

# DevStack : faire tourner rapidement un OpenStack

### Utilité de DevStack

-   Déployer rapidement un OpenStack
-   Utilisé par les développeurs pour tester leurs changements
-   Utilisé pour faire des démonstrations
-   Utilisé pour tester les APIs sans se préoccuper du déploiement
-   Ne doit PAS être utilisé pour de la production

### Fonctionnement de DevStack

-   Un script shell qui fait tout le travail : stack.sh
-   Un fichier de configuration : local.conf
-   Installe toutes les dépendances nécessaires (paquets)
-   Clone les dépôts git (branche master par défaut)
-   Lance tous les composants dans un screen

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

