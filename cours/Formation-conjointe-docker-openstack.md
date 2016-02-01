# Cloud, OpenStack et Docker
Durée : 5 jours
Intervenant : 1 OpenStacker (Lun-Mer), 1 Dockerer (Mer-Ven)

## Description

Cette formation vous permettra de comprendre les enjeux liés au cloud IaaS (Infrastructure as a Service) et d'avoir une vue d'ensemble du fonctionnement d'OpenStack, solution leader du marché. Vous serez en mesure d'utiliser un cloud IaaS, de définir des architectures logicielles et d'infrastructure compatibles cloud. Enfin, vous saurez utiliser un mieux la solution de conteneurs applicatifs Docker.

### À qui s'adresse la formation

La formation s'adresse aux administrateurs système, développeurs et architectes souhaitant découvrir les notions de cloud et de conteneurs applicatifs au travers de d'OpenStack et Docker.

### Pré-requis de la formation

Compétences d’administration système Linux tel qu’Ubuntu, Red Hat ou Debian.
    * Édition de fichiers de configuration
    * Gestion des paquets et des services
    * Notions de virtualisation

### Objectifs

* Comprendre les principes du cloud et son intérêt, ainsi que le vocabulaire associé
* Avoir une vue d’ensemble sur les solutions existantes en cloud public et privé
* Connaître le fonctionnement du projet OpenStack et ses possibilités
* Savoir déployer rapidement un OpenStack de test
* Manipuler l'API (Application Programming Interface), la CLI (Command Line Interface) et le Dashboard
* Pouvoir déterminer ce qui est compatible avec la philosophie cloud
* Posséder les clés pour tirer partie au mieux de l’IaaS
* Comprendre les principes des conteneurs Linux
* Connaître l'écosystème autour de Docker
* Savoir construire une image Docker, l'exécuter, la supprimer
* Construire une application "Dockerisée"
* Utiliser les bons outils pour déployer des conteneurs
* Comprendre les systèmes de clustering pour Docker

## Programme

### Le Cloud : vue d’ensemble

1. Les concepts du Cloud
2. Comprendre le PaaS (Platform as a Service)
3. Comprendre l'IaaS (Infrastructure as a Service)
4. Le stockage dans le cloud, bloc et objet
5. La gestion du réseau SDN (Software Defined Network) et VNF
6. Comment orchestrer les ressources de son IaaS
7. Les APIs, la clé du cloud
8. Conteneurs (LXC, Docker)

### OpenStack

#### Le projet
1. Historique et présentation du projet OpenStack
2. Le logiciel OpenStack
3. Modèle de développement ouvert

#### Utilisation
1. En ligne de commande
2. Via le dashboard web

#### Fonctionnement interne
0. DevStack
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
13. Magnum : Container as a Service
14. Kolla : Déployer OpenStack avec Docker
15. Quelques autres composants intéressants

### Architectures cloud

#### Logiciel
1. 12 factors

#### Infrastructure
1. Isolation
2. Ressources cloud
3. Pets vs Cattle
4. Backup, monitoring, logs
5. Les images cloud
6. Containers

### Docker

#### Conteneurs
- Les conteneurs, encore plus "cloud" qu'une instance
- Namespace, cgroups
- Différents types de conteneurs (LXC / Docker / rkt)
- Conteneur vs instance

#### Les concepts de Docker
- Stockage
- Réseau
- Layers
- Links
- Ports
- Volumes

#### Build : Créer et maintenir une application dockerisée
- Différence entre une image et un conteneur
- Un Dockerfile pour construire une image
- Système de tags
- Bonnes pratiques pour la rédaction d'un Dockerfile
- Focus 1 : les baseimages
- Focus 2 : les layers
- Débuguer les erreurs
- Ex : Construire une application : identification des dépendances, choix de la baseimage, gestion de processus.

#### Ship : Gérer le cycle de vie d'une application
- Travailler avec les conteneurs
- Save, Commit, Import
- Utiliser DockerHub, le "GitHub" de Docker.
- Automated Build avec Github vs Build Standard
- Gestion des builds (CI vs DockerHub)

#### Run
- Les différents modes de "run" (detached et interactive)
- Cycle de vie d'un conteneur
- Reprendre la main sur un conteneur
- Débuguer les erreurs

#### Hosts Docker
- Les OS Linux traditionnels : Debian, Ubuntu, CentOS
- Les OS Linux orientés conteneurs : CoreOS, RancherOS
- Lequel choisir ?

#### Ecosystème Docker
- Compose
- Machine
- Swarm
- Plugins (réseau et stockage)

#### Clustering
- Swarm
- CoreOS
- Rancher
- Kubernetes

#### Construire, déployer et maintenir une infrastructure Docker
- Les outils de déploiement : Terraform et Heat
- Infrastructure as Code n'est plus une option
- Automatisation
- Discovery Service
- Rolling updates
