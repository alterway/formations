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

### Un beau schéma

IaaS/PaaS/SaaS avec les couches

### Cloud public ou privé ?

À qui s'adresse le cloud ?

- Public : tout le monde, disponible sur internet
- Privé : à une organisation, disponible sur son réseau

Concernant le cloud hybride : utilisation mixte de multiples clouds privés et/ou publics

### Cloud hybride

- Concept séduisant
- Mise en œuvre a priori difficile
- Certains cas d'usages s'y prêtent très bien
    - Exemple : jobs de CI

### L'instant virtualisation

Mise au point.

- La virtualisation est une technologie permettant d'implémenter la fonction *compute*
- Un cloud fournissant du compute *peut* utiliser la virtualisation
- Mais peut également utiliser :
    - Du bare-metal
    - Des containers

### Les APIs, la clé du cloud

- Interface de programmation (via le réseau, souvent HTTP)
- Frontière explicite entre le fournisseur (provider) et l'utilisateur (user)
- Définit la manière dont l'utilisateur communique avec le cloud pour gérer ses ressources
- Gérer : CRUD (Create, Read, Update, Delete)

### Pourquoi le cloud ? côté économique

- Appréhender les ressources IT comme des services “fournisseur”
- Faire glisser le budget “investissement” (Capex) vers le budget
“fonctionnement” (Opex)
- Réduire les coûts em mutualisant les ressources, et éventuellement avec des économies d'échelle
- Réduire les délais
- Aligner les coûts sur la consommation réelle des ressources

### Pourquoi le cloud ? côté technique

- Abstraire les couches basses (serveur, réseau, OS, stockage)
- S’affranchir de l’administration technique des ressources et services (BDD, pare-feux, load-balancing, etc.)
- Concevoir des infrastructures scalables à la volée
- Agir sur les ressources via des lignes de code et gérer les infrastructures “comme du code”

## Le marché

### Amazon Web Services (AWS), le leader

- Lancement en 2006
- À l'origine : services web "e-commerce" pour développeurs
- Puis : d'autres services pour développeurs
- Et enfin : services d'infrastructure
- Récemment, SaaS

### Alternatives IaaS publics à AWS

- **Google**
- **Azure**
- Rackspace
- DreamHost
- DigitalOcean
- En France :
    - Cloudwatt
    - Numergy
    - OVH
    - Ikoula
    - Scaleway
    - Outscale

### Faire du IaaS privé

- OpenStack
- CloudStack
- Eucalyptus

### OpenStack en quelques mots

- Naissance en 2010
- Fondation OpenStack depuis 2012
- Écrit en Python et distribué sous licence Apache 2.0
- Soutien très large de l'industrie et contributions variées

## Les concepts Infrastructure as a Service

### La base

- Infrastructure :
    - Compute
    - Storage
    - Network

### Ressources *compute*

- Instance
- Image
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

### Ressources réseau

- Réseau L2
    - Port réseau
- Réseau L3
    - Routeur

### Ressources stockage ?

Le cloud fournit deux types de stockage

- Block
- Objet

### "Boot from volume"

Démarrer une instance avec un disque racine sur un **volume**

- Persistance des données du disque racine
- Se rapproche du serveur classique

### API ... de metadata

- Cloud-init

### Orchestration

- Template
- Stack

## Bonne pratiques d'utilisation

### Infrastructure as Code

Avec du code

- Provisionner les ressources d'infrastructure
- Configurer les dites ressources, notamment les instances

Le métier évolue : Infrastructure Developer

### Scaling, passage à l'échelle

Out vs up

- Auto-scaling ?

### Applications cloud ready

- Stockent leurs données au bon endroit

Cf. <http://12factor.net/>

## Derrière le cloud

### Comment implémenter un service de Compute

- Virtualisation
- Containers
- Bare metal

### Implémentation du réseau : SDN
- Quel rapport avec NFV ?

### Implémentation du stockage : SDS

- Attention : ne pas confondre avec le sujet block vs objet
