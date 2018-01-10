## Avancé

### Un grand cloud

-   Régions
-   Zones de disponibilité (AZ)

### Flavors

-   Un disque de taille nul équivaut à prendre la taille de l’image de base

### Utiliser des images cloud

Une image cloud c’est :

-   Une image disque contenant un OS déjà installé
-   Une image qui peut être instanciée en n machines sans erreur
-   Un OS sachant parler à l’API de metadata du cloud (cloud-init)

Détails : <http://docs.openstack.org/image-guide/openstack-images.html>\
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
