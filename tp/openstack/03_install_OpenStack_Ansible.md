# TP : Installation d'OpenStack à la main

## Objectifs

* Passer en revue les principaux composants d'OpenStack
* Savoir les configurer dans le cadre d'un déploiement simplifié
* Comprendre les liens entre les composants
* Pouvoir diagnostiquer et corriger les erreurs rencontrées

## Démarche

### Déploiement de VMs

On utilise des VMs Ubuntu simulant des nodes physiques :

 * 1 controller node
 * 1 compute node

Avec une configuration réseau simulant les réseaux physiques suivants :

 * Management network
 * Instances network
 * External network

Utilisation de Vagrant (Vagrantfile disponible dans `resources/`) pour le déploiement.

### Procédure d'installation

Utilisation du guide de déploiement officiel `https://docs.openstack.org/project-deploy-guide/openstack-ansible/queens/`.

