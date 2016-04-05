## Développement et fonctionnement du projet

### Le nouveau modèle “big tent”

-   Évolutions récemment implémentées
-   Objectif : résoudre les limitations du précédent modèle incubation/intégré
-   Inclusion a priori de l’ensemble de l’écosystème OpenStack
-   *Programs* $\rightarrow$ *Project Teams*
<http://governance.openstack.org/reference/projects/index.html>
-   Utilisation de tags factuels et objectifs
<https://www.openstack.org/software/project-navigator/>

### Traduction

-   La question de la traduction est dorénavant prise en compte (officialisation de l’équipe *i18n*)
-   Seules certaines parties sont traduites, comme Horizon
-   La traduction française est aujourd’hui une des plus avancées
-   Utilisation de la plateforme Transifex (en cours de migration vers l’outil libre Zanata)

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

![Vue détaillée des services](images/architecture-simple.jpg)

### Cycle de développement : 6 mois

-   Le planning est publié, exemple : <http://releases.openstack.org/mitaka/schedule.html>
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

![Photo : Adrien Cunin](images/photo-summit.jpg)

### Exemple du Summit d’octobre 2015 à Tokyo

![Photo : Elizabeth K. Joseph, CC BY 2.0, Flickr/pleia2](images/photo-summit1.jpg)

### Exemple du Summit d’octobre 2015 à Tokyo

![Photo : Elizabeth K. Joseph, CC BY 2.0, Flickr/pleia2](images/photo-summit2.jpg)

### Exemple du Summit d’octobre 2015 à Tokyo

![Photo : Elizabeth K. Joseph, CC BY 2.0, Flickr/pleia2](images/photo-summit3.jpg)

### Exemple du Summit d’octobre 2015 à Tokyo

![Photo : Elizabeth K. Joseph, CC BY 2.0, Flickr/pleia2](images/photo-summit4.jpg)

### Développement du projet : en détails

-   Ouvert à tous (individuels et entreprises)
-   Cycle de développement de 6 mois débuté par un (design) summit
-   Outils : Launchpad $\rightarrow$ Storyboard (blueprints, bugs) + Git + GitHub (code)
-   Sur chaque patch proposé :
    -   Revue de code (peer review) : Gerrit, <https://review.openstack.org>
    -   Intégration continue (continous integration) : Jenkins, Zuul, etc., <http://zuul.openstack.org/>
-   Développement hyper actif : 17000 commits dans Icehouse (+25%)

### OpenStack Infra

-   Équipe projet en charge de l’infrastructure de développement d’OpenStack
-   Travaille comme les équipes de dev d’OpenStack et utilise les mêmes outils
-   Résultat : une infrastructure entièrement open source et développée comme tel

## DevStack : faire tourner rapidement un OpenStack

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

# Utiliser OpenStack

### Le principe

-   Toutes les fonctionnalités sont accessibles par l’API
-   Les clients (y compris Horizon) utilisent l’API
-   Des crédentials sont nécessaires
    -   API OpenStack : utilisateur + mot de passe + tenant (+ domaine)
    -   API AWS : access key ID + secret access key

### Les APIs OpenStack

-   Une API par service OpenStack
-   <http://developer.openstack.org/api-ref.html>
-   Chaque API est versionnée, la rétro-compatibilité est assurée
-   REST
-   Certains services sont aussi accessibles via une API différente compatible AWS

### Accès aux APIs

-   Direct, en HTTP, via des outils comme curl
-   Avec une bibliothèque
    -   Les implémentations officielles en Python
    -   OpenStackSDK
    -   D’autres implémentations, y compris pour d’autres langages (exemple : jclouds)
    -   Shade
-   Avec les outils officiels en ligne de commande
-   Avec Horizon

### Clients officiels

-   Le projet fournit des clients officiels : python-PROJETclient
-   Bibliothèques Python
-   Outils CLI
    -   L’authentification se fait en passant les credentials par paramètres ou variables d’environnement
    -   L’option –debug affiche la communication HTTP

### OpenStack Client

-   Client CLI unifié
-   Commandes du type *openstack \<service \>\<action \>*
-   Vise à remplacer à terme les clients spécifiques
-   Permet une expérience utilisateur plus homogène

### Authentification et catalogue de service

-   Une fois authentifié, récupération d’un jeton (*token*)
-   Récupération du catalogue de services
-   Pour chaque service, un endpoint HTTP (API)
