# Déployer et opérer OpenStack

### Ce qu’on va voir

-   Installer OpenStack à la main
    <http://docs.openstack.org/ocata/install-guide-ubuntu/>
-   Donc comprendre son fonctionnement
-   Passer en revue chaque composant plus en détails
-   Tour d’horizon des solutions de déploiement

### Architecture détaillée

![Vue détaillée des services](images/architecture.jpg)

### Architecture services

![Machines "physiques" et services](images/archi-service.png)

### Quelques éléments de configuration généraux

-   Tous les composants doivent être configurés pour communiquer avec Keystone
-   La plupart doivent être configurés pour communiquer avec MySQL/MariaDB et RabbitMQ
-   Les composants découpés en plusieurs services ont parfois un fichier de configuration par service
-   Le fichier de configuration `policy.json` précise les droits nécessaires pour chaque appel API

### Système d’exploitation

-   OS Linux avec Python
-   Historiquement : Ubuntu
-   Red Hat s’est largement rattrapé
-   SUSE, Debian, CentOS, etc.

### Python

![Logo Python](images/python-powered.png){height=50px}

-   OpenStack est aujourd’hui compatible Python 2.7
-   Afin de ne pas réinventer la roue, beaucoup de dépendances sont nécessaires
-   Un travail de portage vers Python 3 est en cours

### Base de données

-   Permet de stocker la majorité des données gérées par OpenStack
-   Chaque composant a sa propre base
-   OpenStack utilise l’ORM Python SQLAlchemy
-   Support théorique équivalent à celui de SQLAlchemy
-   MySQL/MariaDB est l’implémentation la plus largement testée et utilisée
-   SQLite est principalement utilisé dans le cadre de tests et démo
-   Certains déploiements fonctionnent avec PostgreSQL

### Pourquoi l’utilisation de SQLAlchemy

![Logo SQLAlchemy](images/sqlalchemy-logo.png){height=40px}

-   Support de multiples BDD
-   Gestion des migrations

![Logo MySQL](images/mysql-logo.png){height=40px}

### Passage de messages

-   AMQP : Advanced Message Queuing Protocol
-   Messages, file d’attente, routage
-   Les processus OpenStack communiquent via AMQP
-   Plusieurs implémentations possibles : Qpid, 0MQ, etc.
-   RabbitMQ par défaut

### RabbitMQ

![Logo RabbitMQ](images/rabbitmq-logo.png){height=40px}

-   RabbitMQ est implémenté en Erlang
-   Une machine virtuelle Erlang est donc nécessaire

### “Hello world” RabbitMQ

![Illustration simple du fonctionnement de RabbitMQ](images/rabbitmq-schema.png)

## Keystone : Authentification, autorisation et catalogue de services

### Principes

-   Annuaire des utilisateurs et des groupes
-   Liste des tenants/projets
-   Catalogue de services
-   Gère l’authentification et l’autorisation
-   Support des domaines dans l’API v3
-   Fournit un token à l’utilisateur

### API

-   API v2 admin : port 35357
-   API v2 utilisateur : port 5000
-   API v3 unifiée : port 5000
-   L'API v2 est dépréciée
-   Gère *utilisateurs*, *groupes*, *domaines* (API v3)
-   Les utilisateurs ont des *rôles* sur des *tenants* (projets)
-   Les *services* du catalogue sont associés à des *endpoints*

### Scénario d’utilisation typique

![Interactions avec Keystone](images/keystone-scenario.png)

### Installation et configuration

-   Paquet : keystone
-   Backends : choix de SQL ou LDAP (ou AD)
-   Backends tokens : SQL, Memcache, aucun
-   Configuration d’un token *ADMIN* pour la configuration initiale
-   Création des services et endpoints
-   Création d'utilisateurs, groupes, domaines

### Enregistrer un service et son endpoint

Il faut renseigner l’existence des différents services (catalogue) dans
Keystone :

    $ keystone service-create --name=cinderv2 --type=volumev2 \
      --description="Cinder Volume Service V2"
    $ keystone endpoint-create \
      --region=myRegion
      --service-id=...
      --publicurl=http://controller:8776/v2/%\(tenant_id\)s \
      --internalurl=http://controller:8776/v2/%\(tenant_id\)s \
      --adminurl=http://controller:8776/v2/%\(tenant_id\)s

### Tester
    $ keystone service-list
    ...
    $ keystone user-list
    ...
    $ keystone token-get
    ...

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
-   Indirectement : images, security groups (groupes de sécurité), floating IPs (IPs flottantes)

Les instances sont redimensionnables et migrables d’un hôte physique à un autre.

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

### Nova api

-   Double rôle
-   API de manipulation des instances par l’utilisateur
-   API à destination des instances : API de metadata
-   L’API de metadata doit être accessible à l’adresse `http://169.254.169.254/`
-   L’API de metadata fournit des informations de configuration personnalisées à chacune des instances

### Nova compute

-   Pilote les instances (machines virtuelles ou physiques)
-   Tire partie de libvirt ou d’autres APIs comme XenAPI
-   Drivers : libvirt (KVM, LXC, etc.), XenAPI, VMWare vSphere, Ironic
-   Permet de récupérer les logs de la console et une console VNC

### Nova scheduler

-   Service qui distribue les demandes d’instances sur les nœuds compute
-   Filter, Chance, Multi Scheduler
-   Filtres, par défaut : AvailabilityZoneFilter,RamFilter,ComputeFilter
-   Tri par poids, par défaut : RamWeigher

### Le scheduler Nova en action

![Fonctionnement de nova-scheduler](images/scheduling-schema.png)

### Nova conductor

-   Service facultatif qui améliore la sécurité
-   Fait office de proxy entre les nœuds compute et la BDD
-   Les nœuds compute, vulnérables, n’ont donc plus d’accès à la BDD

### Tester

    $ nova list
    ...
    $ nova create
    ...

## Glance : Registre d’images

### Principes

-   Registre d’images (et des snapshots)
-   Propriétés sur les images
-   Est utilisé par Nova pour démarrer des instances
-   Peut utiliser Swift comme back-end de stockage

### Propriétés des images dans Glance

L’utilisateur peut définir un certain nombre de propriétés dont certaines seront utilisées lors de  l’instanciation

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

### Backends

-   Swift ou S3
-   Ceph
-   HTTP
-   Répertoire local

### Installation

-   Paquet glance-api : fournit l’API
-   Paquet glance-registry : démon du registre d’images en tant que tel

### Tester
    $ glance image-list
    ...
    $ glance image-create
    ...

## Neutron : Réseau en tant que service

### Principes

-   *Software Defined Networking* (SDN)
-   Auparavant Quantum et nova-network
-   IP flottantes, groupes de sécurité
-   neutron-server : fournit l’API
-   Agent DHCP : fournit le service de DHCP pour les instances
-   Agent L3 : gère la couche 3 du réseau, le routage
-   Plugin : OpenVSwitch par défaut, d’autres implémentations libres/propriétaires, logicielles/matérielles existent

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

### Plugins ML2

-   Modular Layer 2
-   OpenVSwitch
-   OpenDaylight
-   Contrail, OpenContrail
-   Nuage Networks
-   VMWare NSX
-   cf. OpenFlow

### Implémentation

-   Neutron tire partie des namespaces réseaux du noyau Linux pour permettre l’IP overlapping
-   Le proxy de metadata est un composant qui permet aux instances isolées dans leur réseau de joindre l’API de metadata fournie par Nova

### Schéma

![Vue utilisateur du réseau](images/neutron-schema.png)

### Schéma

![Vue infra du réseau](images/neutron-schema2.png)

## Cinder : Stockage block

### Principes

-   Auparavant nova-volume
-   Fournit des volumes (stockage block) attachables aux instances
-   Gère différents types de volume
-   Gère snapshots et backups de volumes
-   Attachement via iSCSI par défaut

### Du stockage partagé ?

-   Cinder n’est **pas** une solution de stockage partagé comme NFS
-   Le projet OpenStack Manila a pour objectif d’être un *NFS as a Service*
-   AWS n’a introduit une telle fonctionnalité que récemment

### Utilisation

-   Volume supplémentaire (et stockage persistant) sur une instance
-   Boot from volume : l’OS est sur le volume
-   Fonctionnalité de backup vers un object store (Swift ou Ceph)

### Installation

-   Paquet cinder-api : fournit l’API
-   Paquet cinder-volume : création et gestion des volumes
-   Paquet cinder-scheduler : distribue les demandes de création de volume
-   Paquet cinder-backup : backup vers un object store

### Backends

-   Utilisation de plusieurs backends en parallèle possible
-   LVM (par défaut)
-   GlusterFS
-   Ceph
-   Systèmes de stockage propriétaires type NetApp
-   DRBD

## Horizon : Dashboard web

### Principes

-   Utilise les APIs existantes pour fournir une interface utilisateur
-   Horizon est un module Django
-   OpenStack Dashboard est l’implémentation officielle de ce module

![Logo du framework web Python Django](images/django-logo.png)

### Configuration

-   `local_settings.py`
-   Les services apparaissent dans Horizon s’ils sont répertoriés dans le catalogue de services de Keystone

### Utilisation

-   Une zone “admin” restreinte
-   Une interface par tenant

## Swift : Stockage objet

### Principes

-   SDS : *Software Defined Storage*
-   Utilisation de commodity hardware
-   Théorème CAP : on en choisit deux
-   Accès par les APIs
-   Architecture totalement acentrée
-   Pas de base de données centrale

### Implémentation

-   Proxy : serveur API par lequel passent toutes les requêtes
-   Object server : serveur de stockage
-   Container server : maintient des listes d’objects dans des containers
-   Account server : maintient des listes de containers dans des accounts
-   Chaque objet est répliqué n fois (3 par défaut)

### Le ring

-   Problème : comment décider quelle donnée va sur quel object server
-   Le ring est découpé en partitions
-   On situe chaque donnée dans le ring afin de déterminer sa partition
-   Une partition est associée à plusieurs serveurs

### Schéma

![Architecture Swift](images/swift-schema.png)

## Ceilometer : Collecte de métriques

### Surveiller l’utilisation de son infrastructure avec Ceilometer

-   Indexe différentes métriques concernant l’utilisation des différents services du cloud
-   Fournit des APIs permettant de récupérer ces données
-   Base pour construire des outils de facturation (exemple : CloudKitty)
-   Utilise MongoDB (par défaut) pour le stockage

### Gnocchi : time-series database

-   Pourquoi Gnocchi ? Palier aux problème de scalabilité de Ceilometer
-   Initié par des développeurs de Ceilometer et intégré à l’équipe projet Ceilometer
-   Back-end remplaçant MongoDB pour Ceilometer

## Heat : Orchestration des ressources

### Orchestrer son infrastructure avec Heat

-   Équivalent d’Amazon Cloud Formation
-   Orchestrer les ressources compute, storage, network, etc.
-   Doit se coupler avec cloud-init
-   Description de son infrastructure dans un fichier template, format JSON (CFN) ou YAML (HOT)

### Autoscaling avec Heat

Heat implémente la fonctionnalité d’autoscaling

-   Se déclenche en fonction des alarmes produites par Ceilometer
-   Entraine la création de nouvelles instances

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

### Fonctionnalités avancées de Heat

-   Nested stacks
-   Environments
-   Providers

### Construire un template à partir d’existant

Multiples projets en cours de développement

-   Flame (Cloudwatt)
-   HOT builder
-   Merlin

## Trove : Database as a Service

### Principe

-   Fournit des bases de données relationnelles, à la AWS RDS
-   A vocation à supporter des bases NoSQL aussi
-   Gère notamment MySQL/MariaDB comme back-end
-   Se repose sur Nova pour les instances dans lesquelles se fait l’installation d’une BDD

### Services

-   trove-api : API
-   trove-taskmanager : gère les instances BDD
-   trove-guestagent : agent interne à l’instance

## Designate : DNS as a Service

### Principe

-   Équivalent d’AWS Route 53
-   Gère différents backends : BIND, etc.

## Barbican - Key management as a Service

-   Gère des secrets / clés privées
-   Backends possibles :
    -    Fichiers chiffrés
    -    PKCS#11
    -    KMIP
    -    Dogtag

## Quelques autres composants intéressants

### Ironic

-   Anciennement Nova bare-metal
-   Permet le déploiement d’instances sur des machines physiques (plutôt que VMs)
-   Repose sur des technologies telles que PXE, TFTP

### Oslo, ou OpenStack common

-   Oslo contient le code commun à plusieurs composants d’OpenStack
-   Son utilisation est transparente pour le déployeur

### rootwrap

-   Wrapper pour l’utilisation de commandes en root
-   Configuration au niveau de chaque composant qui l’utilise
-   Permet d’écrire des filtres sur les commandes

### TripleO

-   OpenStack On OpenStack
-   Objectif : pouvoir déployer un cloud OpenStack (*overcloud*) à partir d’un cloud OpenStack (*undercloud*)
-   Autoscaling du cloud lui-même : déploiement de nouveaux nœuds compute lorsque cela est nécessaire
-   Fonctionne conjointement avec Ironic pour le déploiement bare-metal

### Tempest

-   Suite de tests d’un cloud OpenStack
-   Effectue des appels à l’API et vérifie le résultat
-   Est très utilisé par les développeurs via l’intégration continue
-   Le déployeur peut utiliser Tempest pour vérifier la bonne conformité de son cloud
-   Cf. aussi Rally

## Bonnes pratiques pour un déploiement en production

### Quels composants dois-je installer ?
-   Keystone est indispensable
-   L’utilisation de Nova va de paire avec Glance et Neutron
-   Cinder s’avérera souvent utile
-   Ceilometer et Heat vont souvent ensemble
-   Swift est indépendant des autres composants
-   Neutron peut parfois être utilisé indépendamment (ex : avec oVirt)

<http://docs.openstack.org/arch-design/>

### Penser dès le début aux choix structurants

-   Distribution et méthode de déploiement
-   Hyperviseur
-   Réseau : quelle architecture et quels drivers
-   Politique de mise à jour

### Les différentes méthodes d’installation

-   DevStack est à oublier pour la production
-   TripleO est très complexe
-   Le déploiement à la main comme vu précédemment n’est pas recommandé car peu maintenable
-   Distributions OpenStack packagées et prêtes à l’emploi
-   Distributions classiques et gestion de configuration
-   Déploiement continu

### Mises à jour entre versions majeures

-   OpenStack supporte les mises à jour N $\rightarrow$ N+1
-   Swift : très bonne gestion en mode *rolling upgrade*
-   Autres composants : tester préalablement avec vos données
-   Lire les release notes
-   Cf. articles de blog du CERN

### Mises à jour dans une version stable

-   Fourniture de correctifs de bugs majeurs et de sécurité
-   OpenStack intègre ces correctifs sous forme de patchs dans la branche stable
-   Publication de *point releases* intégrant ces correctifs issus de la branche stable
-   Durée variable du support des versions stables, dépendant de l’intérêt des intégrateurs

### Assigner des rôles aux machines

Beaucoup de documentations font référence à ces rôles :

-   Controller node : APIs, BDD, AMQP
-   Network node : DHCP, routeur, IPs flottantes
-   Compute node : Hyperviseur/pilotage des instances

Ce modèle simplifié n’est pas HA.

### Haute disponibilité

Haute disponibilité du IaaS

-   MySQL/MariaDB, RabbitMQ : HA classique (Galera, Clustering)
-   Les services APIs sont stateless et HTTP : scale out et load balancers
-   La plupart des autres services OpenStack sont capables de scale out également

Guide HA : <http://docs.openstack.org/ha-guide/>

### Haute disponibilité de l’agent L3 de Neutron

-   Plusieurs solutions et contournements possibles
-   Depuis Juno : *Distributed Virtual Router* (DVR)

### Considérations pour une environnement de production

-   Des URLs uniformes pour toutes les APIs : utiliser un reverse proxy
-   Apache/mod\_wsgi pour servir les APIs lorsque cela est possible (Keystone)
-   Utilisation des quotas
-   Prévoir les bonnes volumétries, notamment pour les données Ceilometer
-   Monitoring
-   Backup
-   QoS : en cours d’implémentation dans Neutron

Guide Operations : <http://docs.openstack.org/openstack-ops/content/>

### Utilisation des quotas

-   Limiter le nombre de ressources allouables
-   Par utilisateur ou par tenant
-   Support dans Nova
-   Support dans Cinder
-   Support dans Neutron

<http://docs.openstack.org/user-guide-admin/content/cli_set_quotas.html>

### Découpage réseau

-   Management network : réseau d’administration
-   Data network : réseau pour la communication inter instances
-   External network : réseau externe, dans l’infrastructure réseau existante
-   API network : réseau contenant les endpoints API

### Considérations liées à la sécurité

-   Indispensable : HTTPS sur l’accès des APIs à l’extérieur
-   Sécurisation des communications MySQL/MariaDB et RabbitMQ
-   Un accès MySQL/MariaDB par base et par service
-   Un utilisateur Keystone par service
-   Limiter l’accès en lecture des fichiers de configuration (mots de passe, token)
-   Veille sur les failles de sécurité : OSSA (*OpenStack Security Advisory*), OSSN (*... Notes*)

Guide sécurité : <http://docs.openstack.org/security-guide/>

### Segmenter son cloud

-   Host aggregates : machines physiques avec des caractéristiques similaires
-   Availability zones : machines dépendantes d’une même source électrique, d’un même switch, d’un même DC, etc.
-   Regions : chaque région a son API
-   Cells : permet de regrouper plusieurs cloud différents sous une même API

<http://docs.openstack.org/openstack-ops/content/scaling.html#segregate_cloud>

### Host aggregates / agrégats d’hôtes

-   Spécifique Nova
-   L’administrateur définit des agrégats d’hôtes via l’API
-   L’administrateur associe flavors et agrégats via des couples clé/valeur communs
-   1 agrégat $\equiv$ 1 point commun, ex : GPU
-   L’utilisateur choisit un agrégat à travers son choix de flavor à la création d’instance

### Availability zones / zones de disponibilité

-   Spécifique Nova et Cinder
-   Groupes d’hôtes
-   Découpage en termes de disponibilité : Rack, Datacenter, etc.
-   L’utilisateur choisit une zone de disponibilité à la création d’instance
-   L’utilisateur peut demander à ce que des instances soient démarrées dans une même zone, ou au contraire dans des zones différentes

### Régions

-   Générique OpenStack
-   Équivalent des régions d’AWS
-   Un service peut avoir différents endpoints dans différentes régions
-   Chaque région est autonome
-   Cas d’usage : cloud de grande ampleur (comme certains clouds publics)

### Cells / Cellules

-   Spécifique Nova
-   Un seul nova-api devant plusieurs cellules
-   Chaque cellule a sa propre BDD et file de messages
-   Ajoute un niveau de scheduling (choix de la cellule)

### Packaging d’OpenStack - Ubuntu

-   Le packaging est fait dans de multiples distributions, RPM, DEB et autres
-   Ubuntu est historiquement la plateforme de référence pour le développement d’OpenStack
-   Le packaging dans Ubuntu suit de près le développement d’OpenStack, et des tests automatisés sont réalisés
-   Canonical fournit la Ubuntu Cloud Archive, qui met à disposition la dernière version d’OpenStack pour la dernière Ubuntu LTS

### Ubuntu Cloud Archive (UCA)

![Support d'OpenStack dans Ubuntu via l'UCA](images/ubuntu-cloud-archive.png)

### Packaging d’OpenStack dans les autres distributions

-   OpenStack est intégré dans les dépôts officiels de Debian
-   Red Hat propose RHOS/RDO (déploiement basé sur TripleO)
-   Comme Ubuntu, le cycle de release de Fedora est synchronisé avec celui d’OpenStack

### Les distributions OpenStack

-   StackOps
-   Mirantis
-   HP Helion
-   etc.

### Déploiement bare-metal

-   Le déploiement des hôtes physiques OpenStack peut se faire à l’aide d’outils dédiés
-   MaaS (Metal as a Service), par Ubuntu/Canonical : se couple avec Juju
-   Crowbar / OpenCrowbar (initialement Dell) : utilise Chef
-   eDeploy (eNovance) : déploiement par des images
-   Ironic via TripleO

### Gestion de configuration

-   Puppet, Chef, CFEngine, Saltstack, Ansible, etc.
-   Ces outils peuvent aider à déployer le cloud OpenStack
-   ... mais aussi à gérer les instances (section suivante)

### Modules Puppet, Playbooks Ansible

-   *Puppet OpenStack* et *OpenStack Ansible* : modules Puppet et playbooks Ansible
-   Développés au sein du projet OpenStack
-   <https://wiki.openstack.org/wiki/Puppet>
-   <http://docs.openstack.org/developer/openstack-ansible/install-guide/>

### Déploiement continu

-   OpenStack maintient un master (trunk) toujours stable
-   Possibilité de déployer au jour le jour le `master` (CD : *Continous Delivery*)
-   Nécessite la mise en place d’une infrastructure importante
-   Facilite les mises à jour entre versions majeures

## Gérer les problèmes

### Problèmes : ressources FAILED/ERROR

-   Plusieurs causes possibles
-   Possibilité de supprimer la ressource ?
-   L’appel API *reset-state* peut servir

### Les réflexes en cas d’erreur ou de comportement erroné

-   Travaille-t-on sur le bon tenant ?
-   Est-ce que l’API renvoie une erreur ? (le dashboard peut cacher certaines informations)
-   Si nécessaire d’aller plus loin :
    -   Regarder les logs sur le cloud controller (/var/log/\<composant\>/\*.log)
    -   Regarder les logs sur le compute node et le network node si le problème est spécifique réseau/instance
    -   Éventuellement modifier la verbosité des logs dans la configuration

### Est-ce un bug ?

-   Si le client CLI crash, c’est un bug
-   Si le dashboard web ou une API renvoie une erreur 500, c’est peut-être un bug
-   Si les logs montrent une stacktrace Python, c’est un bug
-   Sinon, à vous d’en juger

