# Docker Hosts

### Les distributions traditionnelles

- Debian, CentOS, Ubuntu

- Supportent tous Docker

- Paquets DEB et RPM disponibles

### Un peu "too much" non ?

- Paquets inutiles ou out of date

- Services par défaut/inutiles alourdissent les distribution

- Cycle de release figé

### OS orienté conteneurs

- Faire tourner le daemon Docker

- Optimisée pour Docker: pas de services superflus 

- Fonctionnalités avancée liées a Docker (clustering, network, etc.)

- Sécurité accrue de part le minimalisme

### OS orientés conteneurs : exemples

- CoreOS

- Atomic (RedHat)

- RancherOS

- Photon (VMware)

- Ubuntu Core (Ubuntu)

### CoreOS : philosophie

- Trois "channels" : stable, beta, alpha

- Dual root : facilité de mise a jour 

- Système de fichier en read only

- Pas de gestionnaire de paquets : tout est conteneurisé 

- Forte intégration de *systemd*

### CoreOS : fonctionnalités orientées conteneurs

- Inclus :
    - Docker
    - Rkt
    - Etcd (base de donnée clé/valeur)
    - Fleet (système d'init distribué)  
    - Flannel (overlay network)

- Permet nativement d'avoir un cluster complet

### CoreOS : Etcd

- Systeme de stockage simple : clé = valeur

- Hautement disponible (quorum)

- Accessible via API

### CoreOS : Fleet

- Système d'init distribué basé sur systemd

- Orchestration de conteneur entre différents hôtes supportant systemd

- S'appuie sur un systeme clé/valeur comme etcd

### CoreOS : Flannel

- Communication multi-host

- UDP ou VXLAN

- S'appuie sur un système clé/valeur comme etcd

### RancherOS : philosophie

- Docker et juste Docker : Docker est le process de PID 1)

- Docker in Docker : Daemon User qui tourne dans le Daemon System

- Pas de processus tierces, pas d'init, juste Docker
