# Docker
Durée : 2 jours  
Intervenant : 1

## Description

Cette formation vous permettra de comprendre les enjeux des systèmes de conteneurs
applicatifs et d'avoir une vue d'ensemble de lu fonctionnement et de l'utilité de Docker,
solution leader du marché. Vous serez en mesure d'utiliser Docker pour construire,
déployer et maintenir vos containers dans un environnement Cloud.

### À qui s'adresse la formation

La formation s'adresse aux administrateurs système, développeurs et architectes souhaitant découvrir les notions autour des conteneurs Docker ainsi que l'écosystème gravitant autour de Docker.

### Pré-requis de la formation

Compétences d’administration système Linux tel qu’Ubuntu, Red Hat ou Debian.
    * Édition de fichiers de configuration
    * Gestion des paquets et des services
    * Notions de virtualisation

### Objectifs

* Comprendre les principes du cloud et son intérêt, ainsi que le vocabulaire associé
* Pouvoir déterminer ce qui est compatible avec la philosophie cloud
* Comprendre les principes des conteneurs Linux
* Connaître l'écosystème autour de Docker
* Savoir construire une image Docker, l'exécuter, la supprimer
* Construire une application "Dockerisée"
* Utiliser les bons outils pour déployer des conteneurs
* Savoir construire une infrastructure fonctionnant avec Docker
* Comprendre les systèmes de clustering pour Docker

## Programme

### Le Cloud : vue d’ensemble

1. Les concepts du Cloud
2. Comprendre le PaaS (Platform as a Service)
3. Comprendre l'IaaS (Infrastructure as a Service)
6. Comment orchestrer les ressources de son IaaS
7. Les APIs, la clé du cloud

### Docker

#### Conteneurs
- Les conteneurs, encore plus "cloud" qu'une instance
- Namespace, cgroups
- Différents types de conteneurs (LXC / Docker / rkt)
- Conteneur vs instance

#### Les concepts de Docker
- Stockage
- Volumes
- Réseau
- Links
- Ports

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

#### Ecosystème Docker
- Compose
- Machine
- Swarm
- Plugins (réseau et stockage)

#### Hosts Docker
- Les OS Linux traditionnels : Debian, Ubuntu, CentOS
- Les OS Linux orientés conteneurs : CoreOS, RancherOS
- Lequel choisir ?
- Gérer ses conteneurs avec Systemd

#### Clustering
- Swarm
- CoreOS
- Rancher
- Kubernetes/Mesos

#### Construire, déployer et maintenir une infrastructure Docker
- Les outils de déploiement : Terraform et Heat
- Infrastructure as Code n'est plus une option
- Automatisation
- Discovery Service
- Rolling updates

