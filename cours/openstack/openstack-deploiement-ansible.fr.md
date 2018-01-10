# Déployer OpenStack avec Ansible

## Rappels : Ansible

- Déploiement de configuration
- Masterless
- Agentless
- Tâches, playbooks, roles
- Inventaire
- Écrit en Python

## OpenStack-Ansible (OSA)

- Projet officiel OpenStack
- Ensemble de playbooks
- Supporte Ubuntu 14.04 et Ubuntu 16.04
- Installation dépendances via apt
- Installation OpenStack/Python via pip et git
- Services déployés dans des containers LXC
- Réseau/Neutron : support linuxbridge, Open vSwitch

## Principaux composants supportés

- Keystone
- Nova
- Neutron
- Cinder
- Ceilometer, Gnocchi, Aodh
- Heat
- Horizon

## Mise en oeuvre de la haute disponibilité (HA)

- HAProxy
- Keepalived
- MySQL : Galera
- RabbitMQ : Clustering

## openstack-ansible-ops

<https://git.openstack.org/cgit/openstack-ansible-ops.git>

