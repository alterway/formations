# Déployer OpenStack

### Ce qu’on va voir

- Installer OpenStack à la main
  <https://docs.openstack.org/install-guide/>
- Donc comprendre son fonctionnement
- Passer en revue chaque composant plus en détails
- Tour d’horizon des solutions de déploiement

### Architecture détaillée

![Vue détaillée des services](images/architecture.jpg)

### Architecture services

![Machines "physiques" et services](images/archi-service.png)

### Quelques éléments de configuration généraux

- Tous les composants doivent être configurés pour communiquer avec Keystone
- La plupart doivent être configurés pour communiquer avec MySQL/MariaDB et RabbitMQ
- Les composants découpés en plusieurs services ont parfois un fichier de configuration par service
- Le fichier de configuration `policy.json` précise les droits nécessaires pour chaque appel API

### Système d’exploitation

- OS Linux avec Python
- Ubuntu
- Red Hat
- SUSE
- Debian, Fedora, CentOS, etc.

### Python

![Logo Python](images/python-powered.png){height=50px}

- OpenStack est compatible Python 2.7
- Comptabilité Python 3 presque complète
- Afin de ne pas réinventer la roue, beaucoup de dépendances sont nécessaires

### Base de données MySQL/MariaDB

- Permet de stocker la majorité des données gérées par OpenStack
- Chaque composant a sa propre base
- OpenStack utilise l’ORM Python SQLAlchemy
- Support théorique équivalent à celui de SQLAlchemy (et support des migrations)
- MySQL/MariaDB est l’implémentation la plus largement testée et utilisée
- SQLite est principalement utilisé dans le cadre de tests et démo
- Certains déploiements fonctionnent avec PostgreSQL

![Logo SQLAlchemy](images/sqlalchemy-logo.png){height=40px}
![Logo MySQL](images/mysql-logo.png){height=40px}

### Passage de messages

- AMQP : Advanced Message Queuing Protocol
- Messages, file d’attente, routage
- Les processus OpenStack communiquent via AMQP
- Plusieurs implémentations possibles : Qpid, 0MQ, etc.
- RabbitMQ par défaut

### RabbitMQ

![Logo RabbitMQ](images/rabbitmq-logo.png){height=40px}

- RabbitMQ est implémenté en Erlang
- Une machine virtuelle Erlang est donc nécessaire

### “Hello world” RabbitMQ

![Illustration simple du fonctionnement de RabbitMQ](images/rabbitmq-schema.png)

### Cache Memcached

- Plusieurs services tirent parti d'un mécanisme de cache
- Memcached est l'implémentation par défaut

## Keystone : Authentification, autorisation et catalogue de services

### Installation et configuration

- Paquet APT : keystone
- Intégration serveur web WSGI (Apache par défaut)
- Fichier de configuration: `/etc/keystone/keystone.conf`
- Backends utilisateurs/groupes : SQL, LDAP (ou Active Directory)
- Backends projets/rôles/services/endpoints : SQL
- Backends tokens : SQL, Memcache, aucun (suivant le type de tokens)

### Drivers pour tokens

- Uuid
- PKI
- Fernet

### Bootstrap

- Création des services et endpoints (à commencer par Keystone)
- Création d'utilisateurs, groupes, domaines
- Fonctionnalité de bootstrap

### Catalogue de services

- 1 service, n endpoints (1 par région)
- 1 endpoint, 3 types :
  - internalURL
  - adminURL
  - publicURL

## Nova : Compute

### Nova api

- Double rôle
- API de manipulation des instances par l’utilisateur
- API à destination des instances : API de metadata
- L’API de metadata doit être accessible à l’adresse `http://169.254.169.254/`
- L’API de metadata fournit des informations de configuration personnalisées à chacune des instances

### Nova compute

- Pilote les instances (machines virtuelles ou physiques)
- Tire partie de libvirt ou d’autres APIs comme XenAPI
- Drivers : libvirt (KVM, LXC, etc.), XenAPI, VMWare vSphere, Ironic
- Permet de récupérer les logs de la console et une console VNC

### Nova scheduler

- Service qui distribue les demandes d’instances sur les nœuds compute
- Filter, Chance, Multi Scheduler
- Filtres, par défaut : AvailabilityZoneFilter,RamFilter,ComputeFilter
- Tri par poids, par défaut : RamWeigher

### Le scheduler Nova en action

![Fonctionnement de nova-scheduler](images/scheduling-schema.png)

### Nova conductor

- Service facultatif qui améliore la sécurité
- Fait office de proxy entre les nœuds compute et la BDD
- Les nœuds compute, vulnérables, n’ont donc plus d’accès à la BDD

## Glance : Registre d’images

### Backends

- Swift ou S3
- Ceph
- HTTP
- Répertoire local

### Installation

- Paquet glance-api : fournit l’API
- Paquet glance-registry : démon du registre d’images en tant que tel

## Neutron : Réseau en tant que service

### Principes

- *Software Defined Networking* (SDN)
- Auparavant Quantum et nova-network
- neutron-server : fournit l’API
- Agent DHCP : fournit le service de DHCP pour les instances
- Agent L3 : gère la couche 3 du réseau, le routage
- Plugin : LinuxBridge par défaut, d’autres implémentations libres/propriétaires, logicielles/matérielles existent

### Fonctionnalités supplémentaires

Outre les fonctions réseau de base niveaux 2 et 3, Neutron peut fournir d’autres services :

- Load Balancing (HAProxy, ...)
- Firewall (vArmour, ...) : diffère des groupes de sécurité
- VPN (Openswan, ...) : permet d’accéder à un réseau privé sans IP flottantes

Ces fonctionnalités se basent également sur des plugins

### Plugins ML2

- **Modular Layer 2**
- LinuxBridge
- OpenVSwitch
- OpenDaylight
- Contrail, OpenContrail
- Nuage Networks
- VMWare NSX
- cf. OpenFlow

### Implémentation

- Neutron tire partie des namespaces réseaux du noyau Linux pour permettre l’IP overlapping
- Le proxy de metadata est un composant qui permet aux instances isolées dans leur réseau de joindre l’API de metadata fournie par Nova

### Schéma

![Vue utilisateur du réseau](images/neutron-schema.png)

### Schéma

![Vue infra du réseau](images/neutron-schema2.png)

## Cinder : Stockage block

### Principes

- Auparavant nova-volume
- Attachement via iSCSI par défaut

### Installation

- Paquet cinder-api : fournit l’API
- Paquet cinder-volume : création et gestion des volumes
- Paquet cinder-scheduler : distribue les demandes de création de volume
- Paquet cinder-backup : backup vers un object store

### Backends

- Utilisation de plusieurs backends en parallèle possible
- LVM (par défaut)
- GlusterFS
- Ceph
- Systèmes de stockage propriétaires type NetApp
- DRBD

## Horizon : Dashboard web

### Principes

- Utilise les APIs existantes pour fournir une interface utilisateur
- Horizon est un module Django
- OpenStack Dashboard est l’implémentation officielle de ce module

![Logo du framework web Python Django](images/django-logo.png)

### Configuration

- `local_settings.py`
- Les services apparaissent dans Horizon s’ils sont répertoriés dans le catalogue de services de Keystone

### Utilisation

- Une zone “admin” restreinte
- Une interface par tenant

## Swift : Stockage objet

### Principes

- SDS : *Software Defined Storage*
- Utilisation de commodity hardware
- Théorème CAP : on en choisit deux
- Accès par les APIs
- Architecture totalement acentrée
- Pas de base de données centrale

### Implémentation

- Proxy : serveur API par lequel passent toutes les requêtes
- Object server : serveur de stockage
- Container server : maintient des listes d’objects dans des containers
- Account server : maintient des listes de containers dans des accounts
- Chaque objet est répliqué n fois (3 par défaut)

### Le ring

- Problème : comment décider quelle donnée va sur quel object server
- Le ring est découpé en partitions
- On situe chaque donnée dans le ring afin de déterminer sa partition
- Une partition est associée à plusieurs serveurs

### Schéma

![Architecture Swift](images/swift-schema.png)

## Ceilometer : Collecte de métriques

### Surveiller l’utilisation de son infrastructure avec Ceilometer

- Indexer et stocker différentes métriques concernant l’utilisation des différents services du cloud
- Fournir des APIs permettant de récupérer ces données
- Base pour construire des outils de facturation (exemple : CloudKitty)

### Ceilometer

- Récupère les données et les stocke
- Historiquement : stockage MongoDB
- Aujourd'hui : stockage Gnocchi

### Gnocchi : time-series database

- Pourquoi Gnocchi ? Palier aux problème de scalabilité de Ceilometer + MongoDB
- Initié par des développeurs de Ceilometer et intégré à l’équipe projet Ceilometer
- Fournit une API pour lire et écrire les données
- Se base sur une BDD relationnelle et un système de stockage objet

## Heat : Orchestration des ressources

### Orchestrer son infrastructure avec Heat

- Équivalent d’Amazon Cloud Formation
- Orchestrer les ressources compute, storage, network, etc.
- Doit se coupler avec cloud-init
- Description de son infrastructure dans un fichier template, format JSON (CFN) ou YAML (HOT)

### Un template HOT

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

## Quelques autres composants intéressants

### Ironic

- Anciennement Nova bare-metal
- Permet le déploiement d’instances sur des machines physiques (plutôt que VMs)
- Repose sur des technologies telles que PXE, TFTP

### Oslo, ou OpenStack common

- Oslo contient le code commun à plusieurs composants d’OpenStack
- Son utilisation est transparente pour le déployeur

### rootwrap -> privsep

- Wrapper pour l’utilisation de commandes en root
- Configuration au niveau de chaque composant qui l’utilise
- Permet d’écrire des filtres sur les commandes

### TripleO

- OpenStack On OpenStack
- Objectif : pouvoir déployer un cloud OpenStack (*overcloud*) à partir d’un cloud OpenStack (*undercloud*)
- Autoscaling du cloud lui-même : déploiement de nouveaux nœuds compute lorsque cela est nécessaire
- Fonctionne conjointement avec Ironic pour le déploiement bare-metal

### Tempest

- Suite de tests d’un cloud OpenStack
- Effectue des appels à l’API et vérifie le résultat
- Est très utilisé par les développeurs via l’intégration continue
- Le déployeur peut utiliser Tempest pour vérifier la bonne conformité de son cloud
- Cf. aussi Rally

