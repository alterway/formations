# Formation OpenStack "Administrateur"

Durée : 3 jours

## Description

Cette formation vous permettra de comprendre les enjeux liés au cloud IaaS (Infrastructure as a Service), puis d'installer et de piloter une infrastructure OpenStack, solution leader du marché.
Elle vous permettra de maîtriser tous les composants et mécanismes de la solution OpenStack.

IaaS est un modèle où les ressources d'infrastructure (telles que calcul, stockage et réseau) sont mises à disposition des utilisateurs par le biais d'APIs. Les APIs permettent l'accès à ces ressources par de multiples moyens : interface graphique/web, ligne de commande, script, programme, etc. Cette possibilité de programmer l'allocation, l'utilisation et la restitution des ressources fait la force du système cloud : mise à l'échelle automatique en fonction de la demande, facturation à l'usage, etc. Les processus deviennent plus agiles. Des clouds publics tels qu'Amazon Web Services (AWS) proposent de l'IaaS. Dans le domaine du cloud privé, c'est le logiciel libre OpenStack qui fait référence.

### Objectifs

* Comprendre les principes du cloud et son intérêt, ainsi que le vocabulaire associé,
* Avoir une vue d’ensemble sur les solutions existantes en cloud public et privé,
* Découvrir OpenStack et manipuler les différents services,
* Connaître le fonctionnement du projet OpenStack et ses possibilités,
* Manipuler l'API (Application Programming Interface), la CLI (Command Line Interface) et le Dashboard,
* Comprendre le fonctionnement de chacun des composants d’OpenStack,
* Pouvoir faire les bons choix de configuration,
* Savoir déployer manuellement un cloud OpenStack pour fournir de l’IaaS,
* Connaitre les bonnes pratiques de déploiement d’OpenStack,
* Être capable de déterminer l’origine d’une erreur dans OpenStack,
* Savoir réagir face à un bug et connaître le processus de correction,
* Posséder les clés pour tirer parti au mieux de l’IaaS.

### Public visé

La formation s'adresse aux administrateurs et architectes souhaitant mettre en place un cloud OpenStack.

### Pré-requis

* Compétences avancées d’administration système Linux tel qu’Ubuntu, Red Hat ou Debian, notamment :
    * Gestion des paquets
    * LVM (Logical Volume Management) et systèmes de fichiers
    * Notions de virtualisation, KVM (Kernel-based Virtual Machine) et libvirt

## Programme

### Le Cloud : vue d’ensemble

1. Les concepts du Cloud
2. Comprendre le PaaS (Platform as a Service)
3. Comprendre l'IaaS (Infrastructure as a Service)
4. Le stockage dans le cloud, block, objet et SDS
5. La gestion du réseau SDN (Software Defined Network) et NFV (Network Functions Virtualization)
6. Comment orchestrer les ressources de son IaaS
7. Les APIs, la clé du cloud

### OpenStack : projet et logiciel

1. Historique et présentation du projet OpenStack
2. Le logiciel OpenStack
3. Modèle de développement ouvert

### Utiliser OpenStack

1. DevStack : faire tourner rapidement un OpenStack
2. Utilisation des APIs
3. Utilisation des outils CLI
4. Utilisation du Dashboard
5. Fonctionnalités avancées

### Déployer OpenStack de A à Z

1. Les briques nécessaires
2. Keystone : Authentification, autorisation et catalogue de services
3. Nova : Compute
4. Glance : Registre d’images
5. Neutron : Réseau en tant que service
6. Cinder : Stockage block
7. Horizon : Dashboard web
8. Swift : Stockage objet
9. Ceilometer : Collecte de métriques
10. Heat : Orchestration des ressources
11. Trove : Database as a Service
12. Designate : DNS as a Service
13. Quelques autres composants intéressants

### OpenStack en production

1. Bonnes pratiques générales
2. Choix structurants
3. Penser le réseau
4. Stratégie pour le stockage
5. Déploiement bare metal et déploiement de configuration
6. Passer à l'échelle
7. Faire face aux problèmes
8. Les mises à jour

### Tirer parti de l’IaaS

1. Penser ses applications pour le cloud
2. Infrastructure as Code
3. Gérer et manipuler ses images cloud
4. Vers le PaaS

### Travaux pratiques

* Installer OpenStack à l'aide de DevStack
* Découvrir le fonctionnement des APIs en effectuant des requêtes HTTP avec curl
* Manipuler les ressources de son cloud à l'aide des outils CLI
* Utiliser le dashboard OpenStack
* Installation d'OpenStack avec les paquets de la distribution
* Déployer une stack avec Heat
* Générer sa propre image cloud
