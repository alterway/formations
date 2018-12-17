# Déployer OpenStack avec Ansible

### Rappels : Ansible

- Déploiement de configuration
- Masterless
- Agentless
- Tâches, playbooks, roles
- Inventaire
- Écrit en Python

### OpenStack-Ansible (OSA)

- Projet officiel OpenStack
- Ensemble de playbooks et de rôles
- Supporte Ubuntu 16.04/18.04, CentOS, openSUSE
- Installation dépendances via apt
- Installation OpenStack/Python via pip et git
- Services déployés dans des *venvs* Python dans des containers LXC
- Réseau/Neutron : support de LinuxBridge, Open vSwitch
- Déploiement de Ceph via `ceph-ansible`

### Principaux composants supportés

- Keystone
- Nova
- Neutron
- Cinder
- Ceilometer, Gnocchi, Aodh
- Heat
- Horizon

### Mise en oeuvre de la haute disponibilité (HA)

- HAProxy
- Keepalived
- MySQL : Galera
- RabbitMQ : Clustering

### Organisation

Sur la *machine de déploiement*

- Composant principal `openstack-ansible`
  - Scripts
  - Inventaire dynamique
  - Playbooks
- Un rôle par service

### Récupérer les rôles

- Adresses et versions sont définis dans `openstack-ansible`/`ansible-role-requirements.yml`
- `scripts/bootstrap-ansible.sh` les télécharge dans `/etc/ansible/roles`

### Configurer

- `/etc/openstack_deploy/`
  - `/etc/openstack_deploy/openstack_user_config.yml`
  - `/etc/openstack_deploy/user_variables.yml`
  - `/etc/openstack_deploy/user_secrets.yml`

### Déployer

- `openstack-ansible setup-everything.yml`
  - `openstack-ansible setup-hosts.yml`
  - `openstack-ansible setup-infrastructure.yml`
  - `openstack-ansible setup-openstack.yml`

### Mettre à jour

- `git pull` d'`openstack-ansible`
- Relancer `scripts/bootstrap-ansible.sh`
- Relancer `openstack-ansible setup-everything.yml`

### openstack-ansible-ops

- Dépôt d'outils pour OSA
- Exemple :
  - Supprimer les anciens *venvs*

<https://git.openstack.org/cgit/openstack-ansible-ops.git>

### Réseau

- LinuxBridge ou Open vSwitch
- DVR possible

### Rsyslog centralisé

- Un container type `rsyslog`
- Tous les services lui transmettent les logs
- Ce `rsyslog` peut lui même transférer les logs ailleurs

### OSA en multi-régions

- Un déploiement OSA par région
- Un déploiement pour le Keystone central

