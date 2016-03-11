# Utiliser OpenStack

### Le principe

-   Toutes les fonctionnalités sont accessibles par l’API
-   Les clients (y compris Horizon) utilisent l’API
-   Des crédentials sont nécessaires
    -   API OpenStack : utilisateur + mot de passe + tenant
    -   API AWS : access key ID + secret access key

### Les APIs OpenStack

-   Une API par service OpenStack
-   <http://developer.openstack.org/#api>
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

### Shade

-   Bibliothèque Python incluant la business logic

### Authentification et catalogue de service

-   Une fois authentifié, récupération d’un jeton (*token*)
-   Récupération du catalogue de services
-   Pour chaque service, un endpoint HTTP (API)

### Utiliser des images cloud

Une image cloud c’est :

-   Une image disque contenant un OS déjà installé
-   Une image qui peut être instanciée en n machines sans erreur
-   Un OS sachant parler à l’API de metadata du cloud (cloud-init)

Détails : <http://docs.openstack.org/image-guide/content/ch_openstack_images.html>\
La plupart des distributions fournissent aujourd’hui des images cloud.

### Cirros

-   Cirros est l’image cloud par excellence
-   OS minimaliste
-   Contient cloud-init 

<https://launchpad.net/cirros>

### Cloud-init

-   Cloud-init est un moyen de tirer partie de l’API de metadata, et notamment des user data
-   L’outil est intégré par défaut dans la plupart des images cloud
-   À partir des user data, cloud-init effectue les opérations de personnalisation de l’instance
-   cloud-config est un format possible de user data

### Exemple cloud-config

    #cloud-config
    mounts:
     - [ xvdc, /var/www ]
    packages:
     - apache2
     - htop

### Comment gérer ses images ?

-   Utilisation d’images génériques et personnalisation à l’instanciation
-   Création d’images intermédiaires et/ou totalement personnalisées :
    *Golden images*
    -   libguestfs, virt-builder, virt-sysprep
    -   diskimage-builder (TripleO)
    -   Packer
    -   solution “maison”

### Propriétés d’une instance

-   Éphémère, a priori non hautement disponible
-   Définie par une flavor
-   Construite à partir d’une image
-   Optionnel : attachement de volumes
-   Optionnel : boot depuis un volume
-   Optionnel : une clé SSH publique
-   Optionnel : des ports réseaux

### Les groupes de sécurité

-   Équivalent à un firewall devant chaque instance
-   Une instance peut être associée à un ou plusieurs groupes de sécurité
-   Gestion des accès en entrée et sortie
-   Règles par protocole (TCP/UDP/ICMP) et par port
-   Cible une adresse IP, un réseau ou un autre groupe de sécurité

### Flavors

-   *Gabarit*
-   Équivalent des “instance types” d’AWS
-   Définit un modèle d’instance en termes de CPU, RAM, disque (racine), disque éphémère
-   Un disque de taille nul équivaut à prendre la taille de l’image de base
-   Le disque éphémère a, comme le disque racine, l’avantage d’être souvent local donc rapide

### Propriétés des images dans Glance

L’utilisateur peut définir un certain nombre de propriétés dont certaines seront utilisées lors de l’instanciation

-   Type d’image
-   Architecture
-   Distribution
-   Version de la distribution
-   Espace disque minimum
-   RAM minimum
-   Publique ou non

### Types d’images

Glance supporte un large éventail de types d’images, limité par le support de l’hyperviseur sous-jacent à Nova

-   raw
-   qcow2
-   ami
-   vmdk
-   iso

### Fonctionnalités supplémentaires

Outre les fonctions réseau de base niveaux 2 et 3, Neutron peut fournir d’autres services :

-   Load Balancing (HAProxy, ...)
-   Firewall (vArmour, ...) : diffère des groupes de sécurité
-   VPN (Openswan, ...) : permet d’accéder à un réseau privé sans IP flottantes

Ces fonctionnalités se basent également sur des plugins

### API

L’API permet notamment de manipuler ces ressources

-   Réseau (*network*) : niveau 2
-   Sous-réseau (*subnet*) : niveau 3
-   Port : attachable à une interface sur une instance, un load-balancer, etc.
-   Routeur

### Un template HOT

*parameters* - *resources* - *outputs*

    heat_template_version: 2013-05-23
    description: Simple template to deploy a single compute instance
    resources:
      my_instance:
        type: OS::Nova::Server
        properties:
          key_name: my_key
          image: F18-x86_64-cfntools
          flavor: m1.small

### Construire un template à partir d’existant

Multiples projets en cours de développement

-   Flame (Cloudwatt)
-   HOT builder
-   Merlin

### Un grand cloud

-   Régions
-   Zones de disponibilité (AZ)

