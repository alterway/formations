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
-   Le corps des requêtes et réponses est formatté avec JSON (auparavant XML était supporté aussi)
-   Architecture REST
-   <https://developer.openstack.org/#api>
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
-   Ou shell interactif
-   Vise à remplacer à terme les clients spécifiques
-   Permet une expérience utilisateur plus homogène
-   Fichier de configuration `clouds.yaml`

<https://docs.openstack.org/python-openstackclient/pike/configuration/index.html#clouds-yaml>

## Keystone : Authentification, autorisation et catalogue de services

### Principes

-   Annuaire des utilisateurs et des groupes
-   Gère des domaines
-   Liste des projets (tenants)
-   Catalogue de services
-   Gère l’authentification et l’autorisation
-   Fournit un token à l’utilisateur

### Authentification et catalogue de service

-   Une fois authentifié, récupération d’un jeton (*token*)
-   Récupération du catalogue de services
-   Pour chaque service, un endpoint HTTP (API)

### API

-   API v2 (dépréciée) : admin port 35357, utilisateur port 5000
-   API v3 : port 5000
-   Gère *utilisateurs*, *groupes*, *domaines*
-   Les utilisateurs ont des *rôles* sur des *projets* (tenants)
-   Les *services* du catalogue sont associés à des *endpoints*

### Scénario d’utilisation typique

![Interactions avec Keystone](images/keystone-scenario.png)

## Nova : Compute

### Principes

-   Gère les instances
-   Les instances sont créées à partir des images fournies par Glance
-   Les interfaces réseaux des instances sont associées à des ports Neutron
-   Du stockage block peut être fourni aux instances par Cinder

### Interactions avec les autres composants

![Instance, image et volume](images/compute-node.png)

### Propriétés d’une instance

-   Éphémère, a priori non hautement disponible
-   Définie par une flavor
-   Construite à partir d’une image
-   Optionnel : attachement de volumes
-   Optionnel : boot depuis un volume
-   Optionnel : une clé SSH publique
-   Optionnel : des ports réseaux

### API

Gère :

-   Instances
-   Flavors (types d’instance)
-   Keypairs
-   Indirectement : images, security groups (groupes de sécurité), floating IPs (IPs flottantes)

Les instances sont redimensionnables et migrables d’un hôte physique à un autre.

## Glance : registre d'images

### Principes

-   Registre d’images (et des snapshots)
-   Propriétés sur les images
-   Est utilisé par Nova pour démarrer des instances

### API

-   API v2 : actuelle
-   API artifacts : future

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

## Neutron : réseau

### API

L’API permet notamment de manipuler ces ressources

-   Réseau (*network*) : niveau 2
-   Sous-réseau (*subnet*) : niveau 3
-   Port : attachable à une interface sur une instance, un load-balancer, etc.
-   Routeur
-   IP flottante, groupe de sécurité

### Les IP flottantes

-   *Allocation* d'une IP depuis un *pool*
-   *Association* d'une IP allouée à un port

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
-   QoS

## Cinder : Stockage block

### Principes

-   Fournit des volumes (stockage block) attachables aux instances
-   Gère différents types de volume
-   Gère snapshots et backups de volumes

### Utilisation

-   Volume supplémentaire (et stockage persistant) sur une instance
-   Boot from volume : l’OS est sur le volume
-   Fonctionnalité de backup vers un object store (Swift ou Ceph)

### Du stockage partagé ?

-   Cinder n’est **pas** une solution de stockage partagé comme NFS
-   Le projet OpenStack Manila a pour objectif d’être un *NFS as a Service*
-   AWS n’a introduit une telle fonctionnalité que récemment

## Heat : Orchestration

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

