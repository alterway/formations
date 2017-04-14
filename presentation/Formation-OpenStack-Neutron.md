# Formation OpenStack Neutron

Durée : 2 jours

## Description

Cette formation vous permettra de monter en compétences sur les composants réseau d'OpenStack et principalement Neutron.

Neutron est la solution de networking intégrée à OpenStack qui permet de gérer diverses fonctions réseau (routeurs, réseaux, sous-réseaux, load-balancers, etc.).

Neutron est un ensemble complexe de composants et dispose également de nombreux plugins qui sont plus ou moins adaptés en fonction du type de déploiement.

### Objectifs

* Pouvoir expliquer le rôle de Neutron
* Comprendre les fonctionnalités offertes par Neutron
* Appréhender les logiques internesà chaque service
* Savoir quel plugin utiliser pour quel déploiement
* Connaitre fonctionnement interne des plugins les plus répandus

### Public visé

La formation s'adresse aux administrateurs et architectes souhaitant mettre en place un cloud OpenStack fournissant des fonctionnalités réseau.

### Pré-requis

* Connaissance d'OpenStack et ses composants
* Connaissance minimale des fonctionnalités réseau offertes par le noyau Linux (bridge, macvlan, tap, veth, iproute2, etc.)
* Être capable de déployer, configurer et opérer un cloud OpenStack

## Programme

### Introduction SDN

* Concepts généraux
* Architecture SDN

### Utilisation de Neutron

* Fonctions réseau de base
    * Networks
    * Subnets
    * Ports
    * Routers
    * Provider networks
* Fonctions réseau étendues
    * Load Balancing
    * Firewall
    * VPN

### Implémentation de Neutron

* neutron-server
* neutron-{plugin}-agent
    * l2pop
    * overlay (vxlan, gre)
* neutron-l3-agent
* neutron-dhcp-agent
* neutron-metadata-agent

#### Les plugins ML2

* LinuxBridge
    * L3 HA avec VRRP
* OpenVSwitch
    * L3 HA avec DVR
* Tour d'horizon des solutions alternatives

### Implémentation Load-balancing as a Service

* Plugin HAProxy
* Plugin Octavia

### Neutron avancé

* Fonctions avancées
    * QoS
    * Subnet pools
    * L2 Gateway
    * BGP
    * Intégration Designate

