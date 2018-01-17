## Utiliser OpenStack - avancé

### Un grand cloud

Tirer partie de :

-   Régions
-   Zones de disponibilité (AZ)

### Flavors

-   Un disque de taille nul équivaut à prendre la taille de l’image de base

### Metadata

-   API
-   Disk drive
-   Vendor data

### Utiliser des images cloud

Une image cloud c’est :

-   Une image disque contenant un OS déjà installé
-   Une image qui peut être instanciée en n machines sans erreur
-   Un OS sachant parler à l’API de metadata du cloud (cloud-init)

Détails : <http://docs.openstack.org/image-guide/openstack-images.html>

La plupart des distributions fournissent aujourd’hui des images cloud.

### Cirros

-   Cirros est l’image cloud par excellence
-   OS minimaliste
-   Contient cloud-init

<https://launchpad.net/cirros>

### Cloud-init

-   Cloud-init est un moyen de tirer parti de l’API de metadata, et notamment des user data
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

### Affinity / anti-affinity dans Nova

### Glance image members

- Partager des images entre projets

## Heat : Orchestration des ressources

### Autoscaling avec Heat

Heat implémente la fonctionnalité d’autoscaling

-   Se déclenche en fonction des alarmes produites par Ceilometer
-   Entraine la création de nouvelles instances

### Fonctionnalités avancées de Heat

-   Nested stacks
-   Environments
-   Providers

### Construire un template à partir d’existant

Multiples projets en cours de développement

-   Flame (Cloudwatt)
-   HOT builder
-   Merlin

### Trove : Database as a Service

-   Fournit des bases de données relationnelles, à la AWS RDS
-   A vocation à supporter des bases NoSQL aussi
-   Gère notamment MySQL/MariaDB comme back-end
-   Se repose sur Nova pour les instances dans lesquelles se fait l’installation d’une BDD

### Designate : DNS as a Service

-   Équivalent d’AWS Route 53

### Barbican : Key management as a Service

-   Gère des secrets / clés privées

