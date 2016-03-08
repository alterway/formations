# Présentation Docker

## Généralités sur les conteneurs
Rappel des notions de cloud computing (instances éphémères, séparation process/data etc)
Différence entre VM, instances et conteneurs
Notions autour du kernel Linux : Namespaces et cgroups
Docker et les autres sytèmes de conteneurs (LXC, rkt)

## Docker
Architecture de Docker :
- storage
- réseau
- layers
- links
- ports exposés
- volumes

## Build
Différence entre une image et un conteneur
Comment constuire un conteneur ?
Les Dockerfile
Best practices pour la rédaction d'un Dockerfile
Présentation de DockerHub

## Ship
Utiliser DockerHub
Apprendre à commit, sauvegarder, importer un conteneur.

## Run
La vie d'un conteneur
- run
- start
- stop
- exec
Présentation des différements mode de fonctionnement d'un conteneur Docker

## Host docker
De quoi a-t-on besoin pour faire fonctionner Docker
- Distributions Linux classiques : Debian, Ubuntu, CentOS
- Distributions Linux orientées Docker : CoreOS, RancherOS
Systemd pour la gestion des conteneurs
Présentation d'ECS, le service Amazon Web Services pour la gestion de
conteneurss

# Docker en application

Docker et la mouvance devops, à quoi ça sert finalement ?
Comment construire proprement une application "dockerisable"
Discovery Service avec Consul (présentation rapide des outils HashiCorp)
Place des conteneurs dans une infrastructure traditionnelle

## Cluster
Comment gérer la haute disponibilité des conteneurs
Résilience des applications en 2016
### Exemples de clustering
- CoreOS
- RancherOS
- Kubernetes

