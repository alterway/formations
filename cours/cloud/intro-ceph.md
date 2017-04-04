### Ceph

-   Projet totalement parallèle à OpenStack
-   Supporté par une entreprise (Inktank) récemment rachetée par Red Hat
-   Fournit d’abord du stockage objet
-   L’accès aux données se fait via RADOS :
    -   Accès direct depuis une application avec librados
    -   Accès via une API REST grâce à radosgw
-   La couche RBD permet d’accéder aux données en mode block (volumes)
-   CephFS permet un accès par un système de fichiers POSIX

