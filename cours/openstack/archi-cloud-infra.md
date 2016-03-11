# Concevoir une infrastructure pour le cloud

### Automatisation

-   Automatiser la gestion de l’infrastructure : indispensable
-   Création des ressources
-   Configuration des ressources

### Infrastructure as Code

-   Travailler comme un développeur
-   Décrire son infrastructure sous forme de code (Heat, Ansible)
-   Suivre les changements dans un VCS (git)
-   Utiliser des outils de tests

### Besoin d’orchestration

-   Manager tous les types de ressources par un point d’entrée
-   Description de l’infrastructure dans un fichier (*template*)
-   Heat (intégré à OpenStack), Terraform

### Tests et intégration continue

-   Style de code
-   Validation de la syntaxe
-   Voire plus si possible

### Autoscaling group

-   Groupe d’instances similaires
-   Nombre variable d’instances
-   Scaling automatique en fonction de métriques

### L’isolation

-   Niveau control plane : Tenant (projet)
-   Niveau réseau : L2, L3, security groups

### Multi-tenant

-   Notion générale : un déploiement du logiciel permet de multiples utilisations
-   Un cloud OpenStack permet aux utilisateurs de travailler dans des environnements isolés
-   Les instances, réseaux, images, etc. sont associés à un tenant
-   Certaines ressources peuvent être partagées entre tenants (exemple :image publique)
-   On peut aussi parler de “projet”

### Les instances

-   Éphémère
-   Pets vs Cattle
-   Basé sur une *image*
-   API de metadata

### L’API de metadata

-   API à destination des instances
-   Standard de fait initié par AWS
-   Accessible depuis l’instance sur http://169.254.169.254/
-   Expose des informations relatives à l’instance
-   Expose un champ libre dit “userdata”

### Réseau

-   Fixed IP
-   Multiples interfaces réseaux
-   Floating IPs : pool, allocate, associate

### Floating IPs

-   *IP flottantes*
-   Surcharge des “Fixed IPs”
-   Non portée par l’instance
-   Souvent une IP “publique”
-   Une fois allouée à un tenant, l’IP est réservée
-   Elle est ensuite associable et désassociable à loisir

### Security groups

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

### Keypairs

-   *Paires de clé*
-   Clés SSH publiques/privés
-   Le cloud a connaissance de la clé publique
-   La clé publique est injectée dans les instances

### Monitoring

Monitoring

-   Prendre en compte le cycle de vie des instances : DOWN != ALERT
-   Monitorer le service plus que le serveur

### Backup

Backuper, quoi ?

-   Être capable de recréer ses instances (et le reste de son infrastructure)
-   Données (applicatives, logs) : block, objet

### Un exemple : l’équipe openstack-infra

-   Équipe projet en charge de l’infrastructure de développement d’OpenStack
-   Travaille comme les équipes de dev d’OpenStack et utilise les mêmes outils
-   Infrastructure as code
-   Infrastructure ouverte : code “open source”
-   Utilise du cloud (hybride)

