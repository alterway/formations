# Formation OpenStack Ops et OpenStack Ansible (déploiement d'OpenStack avec Ansible)

Durée : 4 jours

## Description

Cette formation vous fera découvrir la solution de déploiement OpenStack-Ansible (OSA).

Solution développée au sein du projet OpenStack, OSA permet de déployer tous les principaux composants d'un cloud OpenStack de manière automatisée, tout en restant flexible. Les services peuvent être déployés de manière hautement disponible et être configurés pour répondre aux besoins particuliers.

### Objectifs

* Découvrir OpenStack et manipuler les différents services
* Connaître le fonctionnement du projet OpenStack et ses possibilités
* Comprendre le fonctionnement de chacun des composants d’OpenStack
* Pouvoir faire les bons choix de configuration
* Savoir déployer manuellement un cloud OpenStack pour fournir de l’IaaS
* Connaitre les bonnes pratiques de déploiement d’OpenStack
* Être capable de déterminer l’origine d’une erreur dans OpenStack
* Savoir réagir face à un bug et connaître le processus de correction
* Connaitre la solution de déploiement OpenStack Ansible
* Pouvoir déterminer dans quels cas OSA peut répondre à un besoin
* Être capable de déployer un cloud OpenStack complet avec OSA
* Savoir configurer OSA pour fournir un control-plane hautement disponible
* Savoir configurer les composants OpenStack au travers d'OSA
* Connaitre les procédures d'opération d'un cloud OSA

### Public visé

La formation s'adresse aux administrateurs et architectes souhaitant mettre en place un cloud OpenStack avec la solution de déploiement OSA.

### Pré-requis

* Compréhension des notions cloud
* Utilisation d'un cloud
* Compétences avancées d’administration système Linux tel qu’Ubuntu, Red Hat ou Debian, notamment :
    * Gestion des paquets
    * LVM (Logical Volume Management) et systèmes de fichiers
    * Notions de virtualisation, KVM (Kernel-based Virtual Machine) et libvirt
* Connaissance minimale d'Ansible

## Programme

### OpenStack : projet et logiciel

1. Historique et présentation du projet OpenStack
2. Le logiciel OpenStack
3. Modèle de développement ouvert

### Déployer OpenStack de A à Z

1. Les briques nécessaires
2. Keystone : Authentification, autorisation et catalogue de services
3. Nova : Compute
4. Glance : Registre d’images
5. Neutron : Réseau en tant que service
6. Cinder : Stockage block
7. Horizon : Dashboard web
8. Quelques autres composants intéressants

### OpenStack en production

1. Bonnes pratiques générales
2. Choix structurants
3. Penser le réseau
4. Stratégie pour le stockage
5. Déploiement bare metal et déploiement de configuration
6. Passer à l'échelle
7. Faire face aux problèmes
8. Les mises à jour

### Ansible : rappels

1. Concepts généraux
2. Inventaire
3. Tâches
3. Playbooks
4. Rôles

### Le projet OpenStack-Ansible

1. Pourquoi OpenStack-Ansible ?
2. Développement au sein d'OpenStack
3. Fonctionnalités

### Déployer OpenStack avec OSA

1. Bootstrap
2. Architecture du cloud
3. Configuration du déploiement
4. Configuration des composants d'OpenStack

### Opérer un cloud OSA

1. Mises à jour système
2. Mises à jour OSA
3. Mises à jour OpenStack
4. Gérer une panne
5. Passer à l'échelle son cloud

### Travaux pratiques

* Installer OpenStack à l'aide de DevStack
* Installation d'OpenStack avec les paquets de la distribution
* Adresser des cibles avec la commande ansible
* Écrire un playbook Ansible
* Déployer un cloud OpenStack avec OSA
