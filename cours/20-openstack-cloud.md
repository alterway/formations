# Le Cloud : vue d’ensemble

### Le Cloud : les concepts

-   Puissance de calcul, capacité de stockage et fonctionnalités réseau sous forme de services en-ligne
-   Flexibilité et élasticité des infrastructures
-   Libre-service, notion de catalogue
-   Accès en mode programmatique par des APIs, automatisation
-   Facturation à l’usage

### WaaS : Whatever as a Service

-   Principalement :
    -   IaaS $\rightarrow$ Infrastructure as a Service
    -   PaaS $\rightarrow$ Platform as a Service
    -   SaaS $\rightarrow$ Software as a Service
-   Mais aussi :
    -   Object Storage as a Service
    -   Database as a Service
    -   Load Balancing as a Service
    -   DNS as a Service
    -   \$Application as a Service

### Cloud public, cloud privé, cloud hybride ?

-   Public $\rightarrow$ services cloud proposés par un fournisseur externe (AWS, Rackspace, OVH, etc.)
-   Privé $\rightarrow$ services cloud proposés par une entreprise/organisation à ses propres départements
-   Hybride $\rightarrow$ utilisation des services d’un ou plusieurs clouds publics au sein d’un cloud privé

### Le cloud en un schéma

![](images/cloud.png)

### Pourquoi migrer vers le cloud ? 

Motivations d’ordre économique :

#### appréhender les ressources IT comme des services “fournisseur”
#### réduire les coûts en mutualisant les ressources
#### réduire les délais d’approvisionnement de ressources
#### faire glisser le budget “investissement” (Capex) vers le budget “fonctionnement” (Opex)
#### aligner les coûts sur la consommation réelle des ressources
#### automatiser les opérations sur le SI et le rendre ainsi plus flexible

### Pourquoi migrer vers le cloud ?

Motivations d’ordre technique : 

#### abstraire les couches basses (serveur, réseau, OS, stockage)
#### s’affranchir de l’administration technique des ressources et services (BdD, pare-feux, load balancing,...)
#### concevoir des infrastructures scalables à la volée
#### agir sur les ressources via des lignes de code et gérer les infrastructures “comme du code”

### IaaS : Infrastructure as a Service

### Le leader du IaaS public : Amazon Web Services (AWS)

-   Pionnier du marché (dès 2006)
-   Elastic Compute Cloud ()$\rightarrow$ puissance de calcul
-   Elastic Block Storage ()$\rightarrow$ stockage bloc
-   Simple Storage Service ()$\rightarrow$ stockage objet

### Les clouds publics concurrents d’AWS

-   dans le monde :
    -   Google Cloud Platform
    -   Microsoft Azure
    -   Rackspace
-   en France :
    -   Cloudwatt (Orange Business Services)
    -   Numergy (SFR)
    -   Outscale
    -   OVH
    -   Ikoula
    -   Scaleway (Iliad)

### Logiciels libres permettant le déploiement d’un cloud privé

-   **OpenStack** (https://www.openstack.org)
-   CloudStack (https://cloudstack.apache.org/)
-   Eucalyptus (Acheté par HP en septembre 2014)
-   OpenNebula (http://opennebula.org/)


### Correspondance OpenStack - AWS

-   Compute $\rightarrow$ EC2 $\rightarrow$ Nova
-   Block storage $\rightarrow$ EBS $\rightarrow$ Cinder
-   Object storage $\rightarrow$ S3 $\rightarrow$ Swift
-   Orchestration $\rightarrow$ CFN $\rightarrow$ Heat

### Virtualisation dans le cloud

-   Un cloud IaaS repose souvent sur la virtualisation
-   Ressources “compute” $\leftarrow$ virtualisation
-   Hyperviseurs : KVM, Xen (libvirt), ESX
-   Conteneurs : OpenVZ, LXC, Docker, Kubernetes

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

### OpenStack est une API

-   *Application Programming Interface*
-   Au sens logiciel : Interface permettant à un logiciel d’utiliser une bibliothèque
-   Au sens cloud : Interface permettant à un logiciel d’utiliser un service (XaaS)
-   Il s’agit le plus souvent d’API HTTP REST

### Exemple concret

    GET /v2.0/networks/<network_id>
    {
       "network":{
          "status":"ACTIVE",
          "subnets":[
             "54d6f61d-db07-451c-9ab3-b9609b6b6f0b"
          ],
          "name":"private-network",
          "provider:physical_network":null,
          "admin_state_up":true,
          "tenant_id":"4fd44f30292945e481c7b8a0c8908869",
          "provider:network_type":"local",
          "router:external":true,
          "shared":true,
          "id":"d32019d3-bc6e-4319-9c1d-6722fc136a22",
          "provider:segmentation_id":null
       }
    }


### PaaS : Platform as a Service

### PaaS : concept d’application managée

-   Fourniture d’une plate-forme de “build, deploy and scale”
-   Pour un langage / un framework (Python, Java, PHP, etc.)
-   Principalement utilisé par des développeurs d’applications

### Exemples de PaaS public

-   Amazon Elastic Beanstalk (<https://aws.amazon.com/fr/elasticbeanstalk>)
-   Google App Engine (<https://cloud.google.com/appengine>)
-   Heroku (<https://www.heroku.com>)

### Solutions de PaaS privé

-   Cloud Foundry (<https://www.cloudfoundry.org>)
-   OpenShift (<http://www.openshift.org>)
-   Solum (<https://wiki.openstack.org/wiki/Solum>)

