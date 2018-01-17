# Le cloud, vue d'ensemble

## Définition formelle

### Caractéristiques

Fournir un (des) service(s)...

- Self service
- À travers le réseau
- Mutualisation des ressources
- Élasticité rapide
- Mesurabilité

Inspiré de la définition du NIST <http://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-145.pdf>

### Self service

- L'utilisateur accède *directement* au service
- Pas d'intermédiaire humain
- Réponses immédiates
- Catalogue de services permettant leur découverte

### À travers le réseau

- L'utilisateur accède au service à travers le réseau
- Le *fournisseur* du service est distant du *consommateur*
- Réseau = internet ou pas
- Utilisation de protocoles réseaux standards (typiquement : HTTP)

### Mutualisation des ressources

- Un cloud propose ses services à de multiples utilisateurs/organisations → *Multi-tenant*
- Les ressources sont disponibles en grandes quantités
- La localisation précise et le taux d'occupation des ressources ne sont pas visibles

### Élasticité rapide

- Provisionning et suppression des ressources quasi instantané
- Possibilité d'automatiser ces actions de *scaling* (passage à l'échelle)
- Virtuellement pas de limite à cette élasticité

### Mesurabilité

- L'utilisation des ressources cloud est monitorée par le fournisseur
- Le fournisseur peut gérer son *capacity planning* à partir de ces informations
- L'utilisateur est facturé en fonction de son usage précis des ressources

### Modèles

On distingue :

- modèles de service : IaaS, PaaS, SaaS
- modèles de déploiement : public, privé, hybride

### IaaS

- *Infrastructure as a Service*
- Infrastructure :
    - Compute (calcul)
    - Storage (stockage)
    - Network (réseau)
- Utilisateurs cibles : administrateurs (système, stockage, réseau)

### PaaS

- *Platform as a Service*
- Environnement permettant de développer/déployer une application
- Spécifique à un language/framework (exemple : Python/Django)
- Ressources plus haut niveau que l'infrastructure, exemple : BDD
- Utilisateurs cibles : développeurs d'application

### SaaS

- *Software as a Service*
- Utilisateurs cibles : utilisateurs finaux

### Quelquechose as a Service ?

- Load balancing as a Service (Infra)
- Database as a Service (Platform)
- MonApplication as a Service (Software)
- etc.

### Les modèles de service en un schéma

![IaaS - PaaS - SaaS](images/cloud.png)

### Cloud public ou privé ?

À qui s'adresse le cloud ?

- Public : tout le monde, disponible sur internet
- Privé : à une organisation, disponible sur son réseau

### Cloud hybride

- Utilisation mixte de multiples clouds privés et/ou publics
- Concept séduisant
- Mise en œuvre a priori difficile
- Certains cas d'usages s'y prêtent très bien
    - Intégration continue (CI)
    - Débordement (*cloud bursting*)

### L'instant virtualisation

Mise au point.

- La virtualisation est une technologie permettant d'implémenter la fonction *compute*
- Un cloud fournissant du compute *peut* utiliser la virtualisation
- Mais peut également utiliser :
    - Du bare-metal
    - Des containers

### Les APIs, la clé du cloud

- Rappel : API pour *Application Programming Interface*
    -   Au sens logiciel : Interface permettant à un logiciel d’utiliser une bibliothèque
    -   Au sens cloud : Interface permettant à un logiciel d’utiliser un service (XaaS)
- Interface de programmation (via le réseau, souvent HTTP)
- Frontière explicite entre le fournisseur (provider) et l'utilisateur (user)
- Définit la manière dont l'utilisateur communique avec le cloud pour gérer ses ressources
- Gérer : CRUD (Create, Read, Update, Delete)
- REST

### REST

-   Une ressource == une URI (*Uniform Resource Identifier*)
-   Utilisation des verbes HTTP pour caractériser les opérations (CRUD)
    - GET
    - POST
    - PUT
    - DELETE
-   Utilisation des codes de retour HTTP
-   Représentation des ressources dans le corps des réponses HTTP

### REST - Exemples

    GET http://endpoint/volumes/
    GET http://endpoint/volumes/?size=10
    POST http://endpoint/volumes/
    DELETE http://endpoint/volumes/xyz

### Exemple concret

    GET /v2.0/networks/d32019d3-bc6e-4319-9c1d-6722fc136a22
    {
       "network":{
          "status":"ACTIVE",
          "subnets":[ "54d6f61d-db07-451c-9ab3-b9609b6b6f0b" ],
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

### Pourquoi le cloud ? côté économique

- Appréhender les ressources IT comme des services “fournisseur”
- Faire glisser le budget “investissement” (Capex) vers le budget
“fonctionnement” (Opex)
- Réduire les coûts en mutualisant les ressources, et éventuellement avec des économies d'échelle
- Réduire les délais
- Aligner les coûts sur la consommation réelle des ressources

### Pourquoi le cloud ? côté technique

- Abstraire les couches basses (serveur, réseau, OS, stockage)
- S’affranchir de l’administration technique des ressources et services (BDD, pare-feux, load-balancing, etc.)
- Concevoir des infrastructures scalables à la volée
- Agir sur les ressources via des lignes de code et gérer les infrastructures “comme du code”

## Le marché

### Amazon Web Services (AWS), le leader

![AWS logo](images/aws.png){height=50px}

- Lancement en 2006
- À l'origine : services web "e-commerce" pour développeurs
- Puis : d'autres services pour développeurs
- Et enfin : services d'infrastructure
- Récemment, SaaS

### Alternatives IaaS publics à AWS

- **Google Cloud Platform**
- **Microsoft Azure**
- Rackspace
- DreamHost
- DigitalOcean
- En France :
    - Cloudwatt (Orange Business Services)
    - Numergy (SFR)
    - OVH
    - Ikoula
    - Scaleway
    - Outscale

### Faire du IaaS privé

- **OpenStack**
- CloudStack
- Eucalyptus
- OpenNebula

### OpenStack en quelques mots

![OpenStack logo](images/openstack.png){height="100px"}

- Naissance en 2010
- Fondation OpenStack depuis 2012
- Écrit en Python et distribué sous licence Apache 2.0
- Soutien très large de l'industrie et contributions variées

### Exemples de PaaS public

-   Amazon Elastic Beanstalk (<https://aws.amazon.com/fr/elasticbeanstalk>)
-   Google App Engine (<https://cloud.google.com/appengine>)
-   Heroku (<https://www.heroku.com>)

### Solutions de PaaS privé

-   Cloud Foundry (<https://www.cloudfoundry.org>)
-   OpenShift (<http://www.openshift.org>)
-   Solum (<https://wiki.openstack.org/wiki/Solum>)

## Les concepts Infrastructure as a Service

### La base

- Infrastructure :
    - Compute
    - Storage
    - Network

### Ressources *compute*

- Instance
- Image
- Flavor (gabarit)
- Paire de clé (SSH)

### L'instance

- Éphémère, durée de vie typiquement courte
- Dédiée au compute
- Ne doit pas stocker de données persistantes
- Disque racine non persistant

### Image cloud

- Image disque contenant un OS déjà installé
- Instanciable à l'infini
- Sachant parler à l'API de metadata

### API ... de metadata

- `http://169.254.169.254`
- Accessible depuis l'instance
- Fournit des informations relatives à l'instance
- `cloud-init` permet d'exploiter cette API

### Flavor (gabarit)

-   *Instance type* chez AWS
-   Définit un modèle d’instance en termes de CPU, RAM, disque (racine), disque éphémère
-   Le disque éphémère a, comme le disque racine, l’avantage d’être souvent local donc rapide

### Paire de clé

-   Clé publique + clé privée SSH
-   Le cloud manipule et stocke la clé publique
-   Cette clé publique est utilisée pour donner un accès SSH aux instances

### Ressources réseau 1/2

- Réseau L2
    - Port réseau
- Réseau L3
    - Routeur
    - IP flottante
    - Groupe de sécurité

### Ressources réseau 2/2

- Load Balancing as a Service
- VPN as a Service
- Firewall as a Service

### Ressources stockage

Le cloud fournit deux types de stockage

- Block
- Objet

### Stockage block

- **Volumes** attachables à une instance
- Accès à des raw devices type */dev/vdb*
- Possibilité d’utiliser n’importe quel système de fichiers
- Possibilité d'utiliser du LVM, du chiffrement, etc.
- Compatible avec toutes les applications existantes

### "Boot from volume"

Démarrer une instance avec un disque racine sur un **volume**

- Persistance des données du disque racine
- Se rapproche du serveur classique

### Stockage objet

- Pousser et retirer des objets dans un container/bucket
- Pas de hiérarchie des données, pas de système de fichiers
- Accès par les APIs
- L’application doit être conçue pour tirer parti du stockage objet

### Orchestration

- Orchestrer la création et la gestion des ressources dans le cloud
- Définition de l'architecture dans un *template*
- Les ressources créées à partir du *template* forment la *stack*

## Bonne pratiques d'utilisation

### Haute disponibilité (HA)

- Le control plane (les APIs) du cloud est HA
- Les ressources provisionnées ne le sont pas forcément

### Pets vs Cattle

Comment considérer ses instances ?

- Pet
- Cattle

### Infrastructure as Code

Avec du code

- Provisionner les ressources d'infrastructure
- Configurer les dites ressources, notamment les instances

Le métier évolue : Infrastructure Developer

### Scaling, passage à l'échelle

- Scale out plutôt que Scale up
    - Scale out : passage à l'échelle horizontal
    - Scale up : passage à l'échelle vertical
- Auto-scaling
    - Géré par le cloud
    - Géré par un composant extérieur

### Applications cloud ready

- Stockent leurs données au bon endroit
- Sont architecturées pour tolérer les pannes
- Etc.

Cf. <http://12factor.net/>

## Derrière le cloud

### Comment implémenter un service de Compute

- Virtualisation
- Containers
- Bare metal

### Implémentation du stockage : (Software Defined Storage) SDS

- **Attention** : ne pas confondre avec le sujet block vs objet

- Utilisation de commodity hardware
- Pas de RAID matériel
- Le logiciel est responsable de garantir les données
- Les pannes matérielles sont prises en compte et gérées
- Le projet **Ceph** et le composant **OpenStack Swift** implémentent du SDS
- Voir aussi **Scality**

### SDS - Théorème CAP

![Consistency - Availability - Partition tolerance](images/cap.jpg)

