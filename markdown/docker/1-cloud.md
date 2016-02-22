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

## Les conteneurs

### Encore plus “cloud” qu’une instance

- Partage du kernel

- Un seul process par conteneur

- Le conteneur est encore plus éphèmère que l’instance

- Le turnover des conteneurs est élevé -> orchestration !!

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
