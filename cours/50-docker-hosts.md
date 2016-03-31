# Docker Hosts

### Les distributions traditionnelles

- Debian, CentOS, Ubuntu

- Supportent tous Docker

- Paquets DEB et RPM disponibles

### Un peu "too much" non ?

- Paquets inutiles ou out of date

- Services par défaut/inutiles alourdissent les distributions

- Cycle de release figé

### OS orientés conteneurs

- Faire tourner un conteneur engine

- Optimisé pour les conteneurs : pas de services superflus

- Fonctionnalités avancées liées aux conteneurs (clustering, network, etc.)

- Sécurité accrue de part le minimalisme

### OS orientés conteneurs : exemples

- CoreOS (CoreOS)

- Atomic (RedHat)

- RancherOS (Rancher)

- Photon (VMware)

- Ubuntu Snappy Core (Ubuntu)

### CoreOS : philosophie

- Trois "channels" : stable, beta, alpha

- Dual root : facilité de mise à jour

- Système de fichier en read only

- Pas de gestionnaire de paquets : tout est conteneurisé

- Forte intégration de *systemd*

![](images/docker/coreos.png){height="100px"}

### CoreOS : fonctionnalités orientées conteneurs

- Inclus :
    - Docker
    - Rkt
    - Etcd (base de données clé/valeur)
    - Fleet (système d'init distribué)
    - Flannel (overlay network)

- Permet nativement d'avoir un cluster complet

- Stable et éprouvé en production

- Idéal pour faire tourner Kubernetes (Tectonic)

### CoreOS : Etcd

- Système de stockage simple : clé = valeur

- Hautement disponible (quorum)

- Accessible via API

![](images/docker/etcd.png){height="100px"}

### CoreOS : Fleet

- Système d'init distribué basé sur systemd

- Orchestration de conteneurs entre différents hôtes supportant systemd

- S'appuie sur un système clé/valeur comme etcd

### CoreOS : Flannel

- Communication multi-hosts

- UDP ou VXLAN

- S'appuie sur un système clé/valeur comme etcd

![](images/docker/flannel.png){height="100px"}

### RancherOS : philosophie

- Docker et juste Docker : Docker est le process de PID 1)

- Docker in Docker : Daemon User qui tourne dans le Daemon System

- Pas de processus tiers, pas d'init, juste Docker

- Encore en beta

![](images/docker/rancher.png){height="100px"}

### Fedora Atomic : philosophie

- Équivalent à CoreOS mais basée sur Fedora

- Utilise *systemd*

- Update Atomic (incrémentielles pour rollback)

![](images/docker/atomic.png){height="100px"}

### Project Photon

- Développé par VMware mais Open Source [](https://github.com/vmware/photon)

- Optimisé pour vSphere

- Supporte Docker, Rkt et Pivotal Garden (Cloud Foundry)

![](images/docker/photon.svg){height="100px"}

### Docker Hosts : conclusion

- Répond à un besoin différent des distributions classiques

- Fourni des outils et une logique adaptée aux environnements full conteneurs

- Sécurité accrue (mise à jour)

