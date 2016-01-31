# Présentation Docker

## Généralités sur les containers
Rappel des notions de cloud computing (instances éphémères, séparation process/data etc)
Différence entre VM, instances et containers
Notions autour du kernel Linux : Namespaces et cgroups
Docker et les autres sytèmes de containers (LXC, rkt)

## Docker
Architecture de Docker :
- storage
- réseau
- layers
- links
- ports exposés
- volumes

## Build
Différence entre une image et un container
Comment constuire un container ?
Les Dockerfile
Best practices pour la rédaction d'un Dockerfile
Présentation de DockerHub

## Ship
Utiliser DockerHub
Apprendre à commit, sauvegarder, importer un container.

## Run
La vie d'un container
- run
- start
- stop
- exec
Présentation des différements mode de fonctionnement d'un container Docker

## Host docker
De quoi as-t-on besoin pour faire fonctionner Docker
- Distribution Linux classiques : Debian, Ubuntu, CentOS
- Distribution Linux orientées Docker : CoreOS, RancherOS
Systemd pour la gestion des containers
Présentation d'ECS, le service Amazon Web Services pour la gestion de
containers

# Docker en application

Docker et la mouvance devops, à quoi ça sert finalement ?
Comment construire proprement une application "dockerisable"
Discovery Service avec Consul (présentation rapide des outils HashiCorp)
Place des containers dans une infrastructure traditionnelle

## Cluster
Comment gérer la haute disponibilité des containers
Résilience des applications en 2016
### Exemples de clustering
- CoreOS
- RancherOS
- Kubernetes

