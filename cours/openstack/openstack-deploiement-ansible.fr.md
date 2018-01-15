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
- Supporte Ubuntu 16.04, CentOS, openSUSE
- Installation dépendances via apt
- Installation OpenStack/Python via pip et git
- Services déployés dans des containers LXC
- Réseau/Neutron : support linuxbridge, Open vSwitch
- Déploiement de Ceph

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

- cleanup venvs
<https://git.openstack.org/cgit/openstack-ansible-ops.git>

## Updates

- process update sha1s

## Réseau

- DVR
- OVS

## OSA en multirégions

## Rsyslog centralisé
