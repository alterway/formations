# Utiliser OpenStack

### Le principe

- Toutes les fonctionnalités sont accessibles par l’API
- Les clients (y compris Horizon) utilisent l’API
- Des crédentials sont nécessaires, avec l'API OpenStack :
  - utilisateur
  - mot de passe
  - projet (tenant)
  - domaine

### Les APIs OpenStack

- Une API par service OpenStack
  - Versionnée, la rétro-compatibilité est assurée
  - Le corps des requêtes et réponses est formatté avec JSON
  - Architecture REST
- Les ressources gérées sont spécifiques à un projet

<https://developer.openstack.org/#api>

### Accès aux APIs

- Direct, en HTTP, via des outils comme curl
- Avec une bibliothèque
  - Les implémentations officielles en Python
  - OpenStackSDK
  - D’autres implémentations, y compris pour d’autres langages (exemple : jclouds)
  - Shade (bibliothèque Python incluant la business logic)
- Avec les outils officiels en ligne de commande
- Avec Horizon
- Au travers d'outils tiers, plus haut niveau (exemple : Terraform)

### Clients officiels

- OpenStack fournit des clients officiels
  - Historiquement : `python-PROJETclient` (bibliothèque Python et CLI)
  - Aujourd'hui : `openstackclient` (CLI)
- Outils CLI
  - L’authentification se fait en passant les crédentials par paramètres, variables d’environnement ou fichier de configuration
  - L’option `--debug` affiche la communication HTTP

### OpenStack Client

- Client CLI unifié
- Commandes du type `openstack <ressource> <action>` (shell interactif disponible)
- Vise à remplacer les clients CLI spécifiques
- Permet une expérience utilisateur plus homogène
- Fichier de configuration `clouds.yaml`

<https://docs.openstack.org/python-openstackclient/latest/configuration/index.html#configuration-files>

## Keystone : Authentification, autorisation et catalogue de services

### Principes

Keystone est responsable de l'authentification, l'autorisation et le catalogue de services.

- L'utilisateur standard s'authentifie auprès de Keystone
- L'administrateur intéragit régulièrement avec Keystone

### API

- API v3 : port 5000
- Gère :
  - **Utilisateurs**, **groupes**
  - **Projets** (tenants)
  - **Rôles** (lien entre utilisateur et projet)
  - **Domaines**
  - **Services** et **endpoints** (catalogue de services)
- Fournit :
  - **Tokens** (jetons d'authentification)

### Catalogue de services

- Pour chaque service, plusieurs endpoints sont possibles en fonction de :
  - la région
  - le type d'interface (public, internal, admin)

### Scénario d’utilisation typique

![Interactions avec Keystone](images/keystone-scenario.png)

## Nova : Compute

### Principes

- Gère principalement les **instances**
- Les instances sont créées à partir des images fournies par Glance
- Les interfaces réseaux des instances sont associées à des ports Neutron
- Du stockage block peut être fourni aux instances par Cinder

### Propriétés d’une instance

- Éphémère, a priori non hautement disponible
- Définie par une flavor
- Construite à partir d’une image
- Optionnel : attachement de volumes
- Optionnel : boot depuis un volume
- Optionnel : une clé SSH publique
- Optionnel : des ports réseaux

### API

Ressources gérées :

- **Instances**
- **Flavors** (types d’instance)
- **Keypairs** : ressource propre à l'utilisateur (et non propre au projet)

### Actions sur les instances

- Reboot / shutdown
- Snapshot
- Lecture des logs
- Accès VNC
- Redimensionnement
- Migration (admin)

## Glance : registre d'images

### Principes

- Registre d'images et de snapshots
- Propriétés sur les images

### API

- API v2 : version courante, gère images et snapshots
- API artifacts : version future, plus généraliste

### Types d’images

Glance supporte un large éventail de types d’images, limité par le support de la technologie sous-jacente à Nova

- raw
- qcow2
- ami
- vmdk
- iso

### Propriétés des images dans Glance

L’utilisateur peut définir un certain nombre de propriétés dont certaines seront utilisées lors de l’instanciation

- Type d’image
- Architecture
- Distribution
- Version de la distribution
- Espace disque minimum
- RAM minimum

### Partage des images

- Image publique : accessible à tous les projets
  - Par défaut, seul l'administrateur peut rendre une image publique
- Image partagée : accessible à un ou plusieurs autre(s) projet(s)

### Télécharger des images

La plupart des OS fournissent des images régulièrement mises à jour :

- Ubuntu : <https://cloud-images.ubuntu.com/>
- Debian : <https://cdimage.debian.org/cdimage/openstack/>
- CentOS : <https://cloud.centos.org/centos/>

## Neutron : réseau

### API

L’API permet notamment de manipuler ces ressources :

- Réseau (*network*) : niveau 2
- Sous-réseau (*subnet*) : niveau 3
- Port : attachable à une interface sur une instance, un load-balancer, etc.
- Routeur
- IP flottante, groupe de sécurité

### Les IP flottantes

- En plus des *fixed IPs* portées par les instances
- *Allocation* (réservation pour le projet) d'une IP depuis un *pool*
- *Association* d'une IP allouée à un port (d'une instance, par exemple)
- Non portées directement par les instances

### Les groupes de sécurité

- Équivalent à un firewall devant chaque instance
- Une instance peut être associée à un ou plusieurs groupes de sécurité
- Gestion des accès en entrée et sortie
- Règles par protocole (TCP/UDP/ICMP) et par port
- Cible une adresse IP, un réseau ou un autre groupe de sécurité

### Fonctionnalités supplémentaires

Outre les fonctions réseau de base niveaux 2 et 3, Neutron peut fournir d’autres services :

- Load Balancing
- Firewall : diffère des groupes de sécurité
- VPN : permet d’accéder à un réseau privé sans IP flottantes
- QoS

## Cinder : Stockage block

### Principes

- Fournit des volumes (stockage block) attachables aux instances
- Gère différents types de volume
- Gère snapshots et backups de volumes

### Utilisation

- Volume supplémentaire (et stockage persistant) sur une instance
- Boot from volume : l’OS est sur le volume
- Fonctionnalité de backup vers un object store (Swift ou Ceph)

## Heat : Orchestration

### Généralités

- Heat est la solution native OpenStack, *service* d'orchestration
- Heat fournit une API de manipulation de **stacks** à partir de **templates**
- Un template Heat suit le format HOT (*Heat Orchestration Template*), basé sur YAML

### Un template Heat Orchestration Template (HOT)

*parameters* - *resources* - *outputs*

```yaml
heat_template_version: 2013-05-23
description: Simple template to deploy a single compute instance
resources:
my_instance:
  type: OS::Nova::Server
  properties:
  key_name: my_key
  image: F18-x86_64-cfntools
  flavor: m1.small
```

### Construire un template à partir d’existant

Multiples projets en cours de développement

- Flame (Cloudwatt)
- HOT builder
- Merlin

## Horizon : Dashboard web

### Principes

- Fournit une interface web
- Utilise les APIs existantes pour fournir une interface utilisateur
- Log in possible sans préciser un projet : Horizon détermine la liste des projets accessible

### Utilisation

- Une interface par projet (possibilité de switcher)
- Catalogue de services accessible
- Téléchargement d'un fichier de configuration `clouds.yaml`
- Une zone “admin” restreinte

