## Récapitulatif vocabulaire

### Notions et vocabulaire IaaS 1/4

-   Identité et accès
    -   Tenant/Projet (Project) : locataire du cloud, propriétaire de ressources.
    -   Utilisateur (User) : compte autorisé à utiliser les API OpenStack.
    -   Quota : contrôle l’utilisation des ressources (vcpu, ram, fip, security groups,...) dans un tenant.
    -   Catalogue (de services) : services disponibles et accessibles via les API.
    -   Endpoint : URL permettant l’accès à une API. Un endpoint par service.

### Notions et vocabulaire IaaS 2/4

-   Calcul/Serveurs (Compute)
    -   Image : généralement, un OS bootable et “cloud ready”.
    -   Instance : forme dynamique d’une image.
    -   Type d’instance (flavor) : mensurations d’une instance (cpu, ram, capacité disque,...).
    -   Metadata et user data : informations gérées par le IaaS et mises à disposition de l’instance.
    -   Cloud-init, cloud-config : mécanismes permettant la configuration finale automatique d’une instance.

### Notions et vocabulaire IaaS 3/4

-   Stockage (Storage)
    -   Volume : disque virtuel accessible par les instances (stockage “block”).
    -   Conteneur (Container) : entités logiques pour le stockage de fichiers et accessibles via une URL (stockage “objet”).
-   Réseau et sécurité (Network, Security)
    -   Groupe de sécurité (Security groups) : ensemble de règles de filtrage de flux appliqué à l’entrée des instances.
    -   Paire de clés (Keypairs) : clé privée + clé publique permettant les connexions aux instances via SSH.
    -   IP flottantes (Floating IP) : adresse IP allouée à la demande et utilisée par les instances pour communiquer avec le réseau “externe”.

### Notions et vocabulaire IaaS 4/4

-   Orchestration
    -   Stack : ensemble des ressources IaaS utilisées par une application.
    -   Template : fichier texte contenant la description d’une stack.

