## Stockage : derrière le cloud

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

![Consistency - Availability - Partition tolerance](images/cap.jpg)

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

