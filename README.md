Installation de LaTeX (Ubuntu)
------------------------------

       sudo apt-get install texlive-lang-french texlive


Récupération des fichiers et compilation
----------------------------------------

       git clone git@github.com:Osones/formation-openstack.git
       cd formation-openstack/
       make



## OpenStack administrateur – formation initiale (2 jours)

### Pré-requis de la formation

Compétences d’administration système Linux tel qu’Ubuntu

* Gestion des paquets
* LVM et systèmes de fichiers,
* Notions de virtualisation, KVM et libvirt

Peut servir :

* A l’aise dans un environnement Python

### Objectifs

* Comprendre les principes du cloud et son intérêt
* Connaitre le vocabulaire inhérent au cloud
* Avoir une vue d’ensemble sur les solutions existantes en cloud public et privé
* Posséder les clés pour tirer partie au mieux de l’IaaS
* Pouvoir déterminer ce qui est compatible avec la philosophie cloud ou pas
* Adapter ses méthodes d’administration système à un environnement cloud,
* Connaitre le fonctionnement du projet OpenStack et ses possibilités
* Savoir déployer rapidement un OpenStack de test,
* Utiliser OpenStack (API, CLI, Dashboard).

### Programme

#### Le Cloud : vue d’ensemble 

1. Le Cloud : les concepts 
2. PaaS : Platform as a Service 
3. IaaS : Infrastructure as a Service 
4. Stockage : block, objet, SDS 
5. Réseau : SFN et NFV
6. Orchestrer les ressources de son IaaS 
7. APIs : quel rôle ?

#### OpenStack : projet et logiciel

1. Historique et présentation du projet OpenStack
2. Le logiciel OpenStack 
3. Modèle de développement ouvert

#### Utiliser OpenStack

1. DevStack : faire tourner rapidement un OpenStack
2. Utilisation des APIs
3. Utilisation des outils CLI
4. Utilisation du Dashboard
5. Fonctionnalités avancées


## OpenStack administrateur – formation avancée (3 jours)

### Déployer OpenStack de A à Z

1. Les briques nécessaires 
2. Keystone : Authentification, autorisation et catalogue de services 
3. Nova : Compute 
4. Glance : Registre d’images 
5. Neutron : Réseau en tant que service 
6. Cinder : Stockage block 
7. Horizon : Dashboard web 
8. Swift : Stockage objet 
9. Ceilometer : Collecte de métriques 
10. Heat : Orchestration des ressources 
11. Trove : Database as a Service 
12. Designate : DNS as a Service 
13. Quelques autres composants intéressants 

### OpenStack en production
1. Bonnes pratiques générales
2. Choix structurants
3. Penser le réseau
4. Stratégie pour le stockage
5. Déploiement bare metal et déploiement de configuration
6. Passer à l'échelle
7. Faire face aux problèmes
8. Les mises à jour

### Tirer partie de l’IaaS

1. Penser ses applications pour le cloud 
2. Infrastructure as Code
3. Gérer et manipuler ses images cloud
4. Vers le PaaS



       



