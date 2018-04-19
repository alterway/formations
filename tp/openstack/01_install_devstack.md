# TP : Installer OpenStack via DevStack

## Objectifs

* Mettre en place rapidement un OpenStack utilisable pour démo/test
* Découvrir le fonctionnement de DevStack
* Avoir un moyen de manipuler les APIs OpenStack

## Démarche

### Déploiement d'une VM

Avec Vagrant, déploiement d'une VM Ubuntu.

### Installation de DevStack

Suivi de <http://devstack.org/> (<https://docs.openstack.org/devstack/latest/>).

Dans la VM :

* Installation de git
* Clone du dépôt DevStack
* Configuration minimale pour DevStack (`HOST_IP`)
* `./stack.sh`

