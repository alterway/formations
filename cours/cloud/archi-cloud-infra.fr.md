## Concevoir une infrastructure pour le cloud

### Automatisation

-   Automatiser la gestion de l’infrastructure : indispensable
-   Création des ressources
-   Configuration des ressources

### Infrastructure as Code

-   Travailler comme un développeur
-   Décrire son infrastructure sous forme de code (Heat/Terraform, Ansible)
-   Suivre les changements dans un VCS (git)
-   Mettre en place de la revue de code
-   Utiliser des mécanismes de tests
-   Exploiter des systèmes d'intégration et déploiement continue

### Besoin d’orchestration

-   Manager tous les types de ressources par un point d’entrée
-   Description de l’infrastructure dans un fichier (*template*)
-   Heat (intégré à OpenStack), Terraform

### Tests et intégration continue

-   Style de code
-   Validation de la syntaxe
-   Tests unitaires
-   Tests d'intégration
-   Tests de déploiement complet

### Tolérance aux pannes

-   Tirer parti des capacités de l'application
-   Ne pas tenter de rendre l'infrastructure compute HA

### Autoscaling group

-   Groupe d’instances similaires
-   Nombre variable d’instances
-   Scaling automatique en fonction de métriques
-   Permet le passage à l'échelle *horizontal*

### Monitoring

-   Prendre en compte le cycle de vie des instances : DOWN != ALERT
-   Monitorer le service plus que le serveur

### Backup

-   Être capable de recréer ses instances (et le reste de son infrastructure)
-   Données (applicatives, logs) : block, objet

### Comment gérer ses images ?

-   Utilisation d’images génériques et personnalisation à l’instanciation
-   Création d’images plus ou moins personnalisées :
    -   Modification à froid : libguestfs, virt-builder, virt-sysprep
    -   Modification au travers d'une instance : automatisation possible avec Packer
    -   Construction *from scratch* : diskimage-builder (TripleO)
    -   Construction *from scratch* avec des outils spécifiques aux distributions (`openstack-debian-images` pour Debian)

