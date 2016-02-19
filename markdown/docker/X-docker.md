# Formation Docker

![image](images/docker.png){width="100px"}

## Concernant ces supports de cours

Supports de cours Docker réalisés par Osones (<https://osones.com/>)\
Auteurs :

- Romain Guichard <romain.guichard@osones.com>

- Kevin Lefevre <kevin.lefevre@osones.com>

![image](images/logo-osones-new.png){height="30px"}

- Copyright © 2016 Osones

- Licence : Creative Commons BY-SA 4.0\
  ![image](images/licence.png){width="2.5cm"}\
  <https://creativecommons.org/licenses/by-sa/4.0/deed.fr>

- Sources : <https://github.com/Osones/Formations/>

# Le Cloud : vue d’ensemble

## Le Cloud : les concepts

### Le cloud, c’est large !

- Stockage/calcul distant (on oublie, cf. externalisation)

- Virtualisation++

- Abstraction du matériel (voire plus)

- Accès normalisé par des APIs

- Service et facturation à la demande

- Flexibilité, élasticité

### WaaS : Whatever as a Service

Principalement
- IaaS : Infrastructure as a Service
- PaaS : Platform as a Service
- SaaS : Software as a Service

### Le cloud en un schéma

![image](images/cloud.png){height="200px"}

### Pourquoi du cloud ? Côté technique

- Abstraction des couches basses

- On peut tout programmer à son gré

- Permet la mise en place d’architectures scalables

### Virtualisation dans le cloud

- Le cloud IaaS repose souvent sur la virtualisation

- Ressources compute -> virtualisation

- Virtualisation complète : KVM, Xen

- Virtualisation conteneurs : OpenVZ, LXC, Docker

### Notions et vocabulaire IaaS

- L’instance est par définition éphémère

- Elle doit être utilisée comme ressource de calcul

- Séparer les données des instances

## Orchestrer ses ressources

### Pourquoi orchestrer ?

- Définir tout une infrastructure dans un seul fichier texte

- Autoscaling

- Adapter ses ressources en fonction de ses besoins en temps réel

## Aller encore plus loin

### Encore plus “cloud” qu’une instance

- Partage du kernel

- Un seul process par conteneur

- Le conteneur est encore plus éphèmère que l’instance

- Le turnover des conteneurs est élevé -> orchestration !!

## Le kernel Linux

### Le kernel Linux

- Kernel 2.6.24, janvier 2008

- Namespaces

- cgroups

### Les namespaces

- Mount

- Network

- PID

- Hostname

- User

## Différents types de conteneurs

### LXC

- Développeurs indépendants

- Depuis l’ajout des namespaces et cgroups dans le kernel Linux 2.6.24

### Docker

- Développé par Docker Inc.

- Daemon

- Utilisait la liblxc

- Utilise désormais la libcontainer

### Rocket (rkt)

- Se prononce “rock-it”

- Développé par CoreOS

- Daemon

- Utilise systemd-nspawn

- Adresse certains problèmes de sécurité de Docker

# Vue d’ensemble

## Docker : les concepts

### Un ensemble de composants

- Layers

- Stockage

- Volumes

- Réseau

- Ports

- Links

### Layers : une image

![image](images/docker/image-layers.jpg){height="200px"}

### Layers : un conteneur

![image](images/docker/container-layers.jpg){height="200px"}

### Layers : plusieurs conteneurs

![image](images/docker/sharing-layers.jpg){height="200px"}

### Layers : Répétition des layers

![image](images/docker/saving-space.jpg){height="200px"}

### Stockage : volumes

![image](images/docker/shared-volume.jpg){height="200px"}

### Réseau, link et ports

A la base, pas grand chose...

```
NETWORK ID      NAME      DRIVER
42f7f9558b7a    bridge    bridge
6ebf7b150515    none      null
0509391a1fbd    host      host
```

# Build, Ship and Run !

## Build

### Le conteneur et son image

- Flexibilité et élasticité

### Dockerfile

- lorem ipsum

### Best Practices des Dockerfile

- Comptez vos layers !

- Bien choisir sa baseimage

- schéma montrant les pb de tailles dues à une baseimage de merde

### Présentation de DockerHub

- Intégration GitHub / DockerHub

- screenshot

## Ship

### Les conteneurs sont indépendants !

- Sauvegarder un conteneur :

- docker commit mon-conteneur backup/mon-conteneur

- docker run -it backup/mon-conteneur

- Exporter un conteneur :

- docker save -o mon-image.tar backup/mon-conteneur

- Importe un conteneur :

- docker import mon-image.tar backup/mon-conteneur

### Docker Registry

- DockerHub n’est qu’au Docker registry ce que GitHub est à git

- Pull and Push

## Run

### Lancer un conteneur

- docker run

  - -d (detach)

  - -i (interactive)

  - -t (pseudo tty)

### avec beaucoup d’options...

- -v /directory/host:/directory/container

- -p portHost:portContainer

- -e “VARIABLE=valeur”

- –restart=always

- –name=mon-conteneur

### ...dont certaines un peu dangereuses

- –privileged (Accès à tous les devices)

- –pid=host (Accès aux PID de l’host)

- –net=host (Accès à la stack IP de l’host)

### Se “connecter” à un conteneur

- docker exec

- docker attach

### Détruire un conteneur

- docker kill (SIGKILL)

- docker stop (SIGTERM puis SIGKILL)

- docker rm (détruit complètement)

## Ecosystème

### Docker Inc. et OCI

- TBC

## Les autres produits Docker

### Compose

- schema

### Machine

- Schéma

### Swarm

- Schéma

### Plugins réseau et stockage

- Schéma

## Docker Hosts
