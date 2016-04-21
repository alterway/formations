# Monitorer une infrastructure Docker

## Quoi monitorer ?

- L'infrastructure

- Les conteneurs

## Monitorer son infrastructure

- Problématique classique

Monitorer des serveur est une problématique résolu depuis de nombreuses années par des outils devenus des standards :

- Nagios

- Shinken

- Centreons

- Icinga

### Intérêt ?

- Un des principes du cloud computing est d'abstraire les couches basses

- Docker accentue cette pratique

- Est-ce intéressant de monitorer son infra ?

###

Oui bien sûr ;)

## Monitorer ses conteneurs

- Monitorer les services fournis par les conteneurs

- Monitorer l'état d'un cluster

- Monitorer un conteneur spécifique

### Problématiques des conteneurs

- Les conteneurs sont des boîtes noires

- Les conteneurs sont dynamiques

- La scalabilité induite par les conteneurs devient un problème

### Monitorer les services

- La problématique est différente pour chaque service

- Concernant les web services (grande majorité), le temps de réponse du service et la disponibilité du service sont de bons indicatifs

- Problème adressé par certains services discovery pour conserver une vision du système cohérente (ex : [Consul](http://www.consul.io)

### Monitorer l'état d'un cluster

- Dépends grandement de la technologie employée

- Le cluster se situe t-il au niveau de l'host Docker ou des conteneurs eux mêmes ?

### Monitorer, OK mais depuis où ?

- Commandes exécutées dans le container

- Agents à l'intérieur du conteneur

- Agents à l'extérieur du conteneur

## Les outils de monitoring

- Docker stats

- CAdvisor

- Datadog

- Sysdig
