# Formation OpenStack Neutron

Durée : 2 jours

## Description

Cette formation vous permettra de monter en compétences sur les composants réseaux d'OpenStack.

Neutron est la solution de networking intégrée à OpenStack qui permet de créer diverses fonctions réseaux virtuelles (routeurs, réseaux, sous-réseaux, load-balancers, etc.).

Neutron est un ensemble complexe de composants et dispose également de nombreux plugins qui sont plus ou moins adaptés en fonction du type de déploiement.

### Objectifs

* Présentation de Neutron
* Les fonctions proposées par Neutron
* Comprendre le fonctionnement de chaque service
* État de l'art des plugins Neutron
* Savoir quel plugin utiliser pour quel déploiement
* Rentrer en détails sur le fonctionnement interne des plugins les plus répandus

### Public visé

La formation s'adresse aux administrateurs et architectes souhaitant mettre en place un cloud OpenStack fournissant des fonctionnalités réseau.

### Pré-requis

* Connaissance minimale d'OpenStack et ses composant
* Connaissance minimal des fonctionnalité réseaux offertes par le Kernel Linux (bridge, macvlan, tap, veth, iproute2, etc.)
* Être capable de déployer, configurer et opérer un cloud OpenStack

## Programme

### Neutron : Présentation

1. Concepts généraux
2. Fonction réseaux de base
3. Fonction réseaux étendus
4. Architecture

### Neutron : Les services

1. neutron-server
2. neutron-l3-agent
3. neutron{plugin}-agent
4. neutron-metadata-agent
5. neutron-dhcp-agent

### Neutron : Les plugins

* OpenVSwitch
* LinuxBridge

### Neutron : Load-balancing

* API
* Plugin HAProxy
* Plugin Octavia

