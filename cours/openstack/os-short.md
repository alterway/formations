![image](images/openstack.png){width="100px"}

Introduction {#introduction .unnumbered}
============

### Introduction

-   Le cloud recouvre beaucoup de notions

-   On s’intéresse ici à l’ (Infrastructure as a Service) - c’est quoi ?

-   OpenStack : logiciel libre permettant de déployer une plateforme
    IaaS

-   Et le stockage ?

-   Orchestration des ressources de l’infrastructure

### Qui suis-je ?

-   Adrien Cunin

    -   24 ans et passionné de logiciels libres

    -   Contributeur depuis 2006 (notamment Ubuntu et Debian)

    -   Ingénieur cloud computing / OpenStack

    ![image](images/logo-osones.png){width="3cm"}

-   Osones

    -   Services et formations cloud computing (OpenStack, AWS)

-   Association OpenStack-fr

    -   Membre du CA et co-fondateur

### Plan

Le cloud, de quoi parle-t-on ?
==============================

### Le cloud, c’est large !

-   Stockage/calcul distant (on oublie, cf. externalisation)

-   Virtualisation++

-   Abstraction du matériel (voire plus)

-   Accès normalisé par des APIs

-   Service et facturation à la demande

-   Flexibilité, elasticité

### WaaS : Whatever as a Service

-   Principalement

    IaaS :

    PaaS

    :   Platform as a Service

    SaaS

    :   Software as a Service

-   Mais aussi :

    -   Database as a Service

    -   Network as a Service

    -   Load balancing as a Service

    -   \$APPLICATION as a Service

### Cloud public ou cloud privé ?

-   fourni par un hébergeur à des clients (AWS, Rackspace Cloud, etc.);
    cloud externalisé

-   plateforme et ressources internes

-   utilisation de ressources publiques en complément d’un cloud privé,
    lorsque le besoin apparait (*cloud bursting*)

### Amazon Web Services (AWS) et les autres

-   Service (cloud public) :

    -   Pionnier du genre (dès 2002)

    -   Elastic Compute Cloud ()

    -   Elastic Block Storage (EBS)

    -   Simple Storage Service ()

-   Logiciels libres permettant le déploiement d’un cloud privé :

    -   Eucalyptus

    -   CloudStack

    -   OpenNebula

    -   **OpenStack**

### Notions et vocabulaire IaaS

-   Images

-   Instances

-   Volumes

-   Stockage block

-   Stockage objet

-   API REST

### À retenir

### AWS

Le projet OpenStack : présentation
==================================

### Résumé

![image](images/openstack-software-diagram.pdf){width="\textwidth"}

### Historique

-   Démarrage en 2010

-   Objectif : le Cloud Operating System libre

-   Fusion de deux projets de Rackspace (Storage) et de la NASA
    (Compute)

-   Licence Apache 2.0

-   Les releases jusqu’à aujourd’hui :

    -   Austin (2010.1)

    -   Bexar (2011.1)

    -   Cactus (2011.2)

    -   Diablo (2011.3)

    -   Essex (2012.1)

    -   Folsom (2012.2)

    -   Grizzly (2013.1)

    -   Havana (2013.2)

    -   Icehouse (2014.1)

    -   **Juno (2014.2)**

    -   Avril 2015 : Kilo

### Quelques soutiens/contributeurs ...

-   NASA

-   Bull

-   Mais aussi : , StackOps, eNovance (racheté par Red Hat)

http://www.openstack.org/foundation/companies/

### ... et utilisateurs

-   Tous les contributeurs précédemment cités

-   En France : **CloudWatt** et **Numergy**

-   Wikimedia

-   CERN

-   Paypal

-   Comcast

-   BMW

-   Etc. Sans compter les implémentations confidentielles

http://www.openstack.org/user-stories/

### Les différents sous-projets

-   OpenStack Compute - Nova{}

-   OpenStack (Object) Storage - Swift

-   OpenStack Block Storage - Cinder

-   OpenStack Networking - Neutron

-   OpenStack Image Service - Glance

-   OpenStack Identity Service - Keystone

-   OpenStack Dashboard - Horizon

-   OpenStack Telemetry - Ceilometer

-   OpenStack Orchestration - Heat

### Les différents sous-projets (2)

-   Incubating et/ou intéressants

    -   Database service (Trove)

    -   Bare metal (Ironic)

    -   Queue service (Zaqar)

    -   Data processing (Sahara)

    -   DNS service (Designate)

    -   PaaS (Solum)

### Architecture conceptuelle

![image](images/architecture-conceptual.jpg){width="\textwidth"}

### Développement du projet

-   Open Source

-   Open Design

-   Open Development

-   Open Community

### Développement du projet : en détails

-   Ouvert à tous (individuels et entreprises)

-   Cycle de développement de 6 mois débuté par un (design) summit

-   Outils : Launchpad (blueprints, bugs) + git (code)

-   Sur chaque commit : peer review (Gerrit) + tests automatisés
    (Jenkins)

-   Plateforme de référence et modèle de développement : Ubuntu

-   Développement hyper actif

-   Fin 2012, création d’une entité indépendante de gouvernance : la
    fondation OpenStack

### Fondation OpenStack

![image](images/foundation.png){width="\textwidth"}

### Design Tenets

1.  Scalability and elasticity are our main goals

2.  Any feature that limits our main goals must be optional

3.  Everything should be asynchronous. If you can’t do something
    asynchronously, see \#2

4.  All required components must be horizontally scalable

5.  Always use shared nothing architecture (SN) or sharding. If you
    can’t Share nothing/shard, see \#2

6.  Distribute everything. Especially logic. Move logic to where state
    naturally exists.

7.  Accept eventual consistency and use it where it is appropriate.

8.  Test everything. We require tests with submitted code. (We will help
    you if you need it)

### Implémentation

-   Chaque sous-projet est découpé en plusieurs services

-   Communication entre les services : AMQP (RabbitMQ)

-   Base de données : relationnelle (MySQL)

-   Réutilisation de nombreux composants existants

-   SDN, SDS, ...

-   Gère deux APIs : OpenStack et AWS

### Architecture logique

![image](images/architecture.jpg){width="\textwidth"}

### Interface web / Dashboard : Horizon

![image](images/horizon.png){width="\textwidth"}

### Orchestrer son infrastructure avec Heat

-   Équivalent d’Amazon Cloud Formation

-   Orchestrer les ressources compute, storage, network, etc.

-   Sait tirer partie de Ceilometer pour faire de l’autoscaling

-   Doit se coupler avec cloud-init

-   Description de son infra dans un fichier template, format JSON (CFN)
    ou YAML

Conclusion {#conclusion .unnumbered}
==========

### Conclusion

-   Le cloud révolutionne la manière de gérer les ressources (IaaS pour
    les infrastructures)

-   OpenStack est le projet libre reconnu en matière de cloud IaaS (et
    de plus en plus PaaS)

-   Le projet avance a une vitesse impressionnante

-   Sur la partie stockage / SDS, voir Ceph

### Démonstration

Démonstration
