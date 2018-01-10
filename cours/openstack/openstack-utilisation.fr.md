# Utiliser OpenStack

### Le principe

-   Toutes les fonctionnalités sont accessibles par l’API
-   Les clients (y compris Horizon) utilisent l’API
-   Des crédentials sont nécessaires
    -   API OpenStack : utilisateur + mot de passe + projet (tenant) + domaine
    -   API AWS : access key ID + secret access key

### Les APIs OpenStack

-   Une API par service OpenStack
-   Chaque API est versionnée, la rétro-compatibilité est assurée
-   Le corps des requêtes et réponses est formatté avec JSON
-   Architecture REST
-   <http://developer.openstack.org/#api>
-   Certains services sont aussi accessibles via une API différente compatible AWS

### Accès aux APIs

-   Direct, en HTTP, via des outils comme curl
-   Avec une bibliothèque
    -   Les implémentations officielles en Python
    -   OpenStackSDK
    -   D’autres implémentations, y compris pour d’autres langages (exemple : jclouds)
    -   Shade (bibliothèque Python incluant la business logic)
-   Avec les outils officiels en ligne de commande
-   Avec Horizon

### Clients officiels

-   Le projet fournit des clients officiels : python-PROJETclient
-   Bibliothèques Python
-   Outils CLI
    -   L’authentification se fait en passant les credentials par paramètres ou variables d’environnement
    -   L’option `--debug` affiche la communication HTTP

### OpenStack Client

-   Client CLI unifié
-   Commandes du type *openstack \<ressource \>\<action \>*
-   Vise à remplacer à terme les clients spécifiques
-   Permet une expérience utilisateur plus homogène
-   Fichier de configuration `clouds.yaml`

<https://docs.openstack.org/python-openstackclient/pike/configuration/index.html#clouds-yaml>

## Authentification

### Authentification et catalogue de service

-   Une fois authentifié, récupération d’un jeton (*token*)
-   Récupération du catalogue de services
-   Pour chaque service, un endpoint HTTP (API)

### Scénario d’utilisation typique

![Interactions avec Keystone](images/keystone-scenario.png)

## Compute

### Propriétés d’une instance

-   Éphémère, a priori non hautement disponible
-   Définie par une flavor
-   Construite à partir d’une image
-   Optionnel : attachement de volumes
-   Optionnel : boot depuis un volume
-   Optionnel : une clé SSH publique
-   Optionnel : des ports réseaux

### Types d’images

Glance supporte un large éventail de types d’images, limité par le support de l’hyperviseur sous-jacent à Nova

-   raw
-   qcow2
-   ami
-   vmdk
-   iso

### Propriétés des images dans Glance

L’utilisateur peut définir un certain nombre de propriétés dont certaines seront utilisées lors de l’instanciation

-   Type d’image
-   Architecture
-   Distribution
-   Version de la distribution
-   Espace disque minimum
-   RAM minimum
-   Publique ou non

## Réseau

### API

L’API permet notamment de manipuler ces ressources

-   Réseau (*network*) : niveau 2
-   Sous-réseau (*subnet*) : niveau 3
-   Port : attachable à une interface sur une instance, un load-balancer, etc.
-   Routeur

### Les groupes de sécurité

-   Équivalent à un firewall devant chaque instance
-   Une instance peut être associée à un ou plusieurs groupes de sécurité
-   Gestion des accès en entrée et sortie
-   Règles par protocole (TCP/UDP/ICMP) et par port
-   Cible une adresse IP, un réseau ou un autre groupe de sécurité

### Fonctionnalités supplémentaires

Outre les fonctions réseau de base niveaux 2 et 3, Neutron peut fournir d’autres services :

-   Load Balancing
-   Firewall : diffère des groupes de sécurité
-   VPN : permet d’accéder à un réseau privé sans IP flottantes

## Orchestration

### Natif OpenStack et alternatives

- Heat est la solution native OpenStack
- Heat fournit une API de manipulation de *stacks* à partir de *templates*
- Des alternatives externes à OpenStack existent, comme **Terraform**

### Un template Heat Orchestration Template (HOT)

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

