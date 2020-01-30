# OpenStack : le projet

## Tour d'horizon

### Vue haut niveau

![Version simple](images/openstack-software-diagram.png)

### Historique

-   Démarrage en 2010
-   Objectif : le Cloud Operating System libre
-   Fusion de deux projets de Rackspace (Storage) et de la NASA (Compute)
-   Logiciel libre distribué sous licence Apache 2.0
-   Naissance de la Fondation en 2012

### Mission statement

```To produce a ubiquitous Open Source Cloud Computing platform that is
easy to use, simple to implement, interoperable between deployments,
works well at all scales, and meets the needs of users and operators of
both public and private clouds.```

### Les releases

-   Austin (2010.1)
-   Bexar (2011.1), Cactus (2011.2), Diablo (2011.3)
-   Essex (2012.1), Folsom (2012.2)
-   Grizzly (2013.1), Havana (2013.2)
-   Icehouse (2014.1), Juno (2014.2)
-   Kilo (2015.1), Liberty (2015.2)
-   Mitaka (2016.1), Newton (2016.2)
-   Ocata (2017.1), Pike (2017.2)
-   Queens (2018.1), **Rocky** (2018.2)
-   Stein (2019.1), Train (2019.2)
-   Premier semestre 2020 : Ussuri

### Quelques soutiens/contributeurs ...

- Editeurs : Red Hat, Suse, Canonical, Vmware, ...
- Constructeurs : IBM, HP, Dell, ...
- Constructeurs/réseau : Juniper, Cisco, ...
- Constructeurs/stockage : NetApp, Hitachi, ...
- En vrac : NASA, Rackspace, Yahoo, OVH, Citrix, SAP, ...
-  **Google** ! (depuis juillet 2015)

<https://www.openstack.org/foundation/companies/>

### ... et utilisateurs

-   Tous les contributeurs précédemment cités
-   En France : **Cloudwatt** et **Numergy**
-   Wikimedia
-   CERN
-   Paypal
-   Comcast
-   BMW
-   Etc. Sans compter les implémentations confidentielles

<https://www.openstack.org/user-stories/>

### Les différents sous-projets

<https://www.openstack.org/software/project-navigator/>

-   OpenStack Compute - Nova
-   OpenStack (Object) Storage - Swift
-   OpenStack Block Storage - Cinder
-   OpenStack Networking - Neutron
-   OpenStack Image Service - Glance
-   OpenStack Identity Service - Keystone
-   OpenStack Dashboard - Horizon
-   OpenStack Telemetry - Ceilometer
-   OpenStack Orchestration - Heat

### Les différents sous-projets (2)

-   Mais aussi :
    -   Bare metal (Ironic)
    -   Queue service (Zaqar)
    -   Database Service (Trove)
    -   Data processing (Sahara)
    -   DNS service (Designate)
    -   Shared File Systems (Manila)
    -   Key management (Barbican)
    -   Container (Magnum)
-   Autres
    -   Les clients CLI et bibliothèques
    -   Les outils de déploiement d'OpenStack
    -   Les bibliothèques utilisées par OpenStack
    -   Les outils utilisés pour développer OpenStack

### APIs

-   Chaque projet supporte *son* API OpenStack
-   Certains projets supportent l'API AWS équivalente (Nova/EC2, Swift/S3)

### Les 4 Opens

-   Open Source
-   Open Design
-   Open Development
-   Open Community

<https://governance.openstack.org/tc/reference/opens.html>

<https://www.openstack.org/four-opens/>

### La Fondation OpenStack

-   Entité de gouvernance principale et représentation juridique du projet
-   Les membres du board sont issus des entreprises sponsors et élus par les membres individuels
-   Tout le monde peut devenir membre individuel (gratuitement)
-   Ressources humaines : marketing, événementiel, release management, quelques développeurs (principalement sur l’infrastructure)
-   600 organisations à travers le monde
-   80000 membres individuels dans 170 pays

### La Fondation OpenStack

![Les principales entités de la Fondation](images/foundation.png)

### Open Infrastructure

-   Récemment, la Fondation OpenStack s'élargit à l'**Open Infrastructure**
-   Au-delà d'OpenStack, nouveaux projets chapeautés :
    -   Kata Containers
    -   Zuul
    -   Airship
    -   StarlingX

### Ressources

-   Annonces (nouvelles versions, avis de sécurité) : <openstack-announce@lists.openstack.org>
-   Portail documentation : <https://docs.openstack.org/>
-   API/SDK : <https://developer.openstack.org/>
-   Gouvernance du projet : <https://governance.openstack.org/>
-   Versions : <https://releases.openstack.org/>
-   Support :
    -   <https://ask.openstack.org/>
    -   openstack-discuss@lists.openstack.org
    -   \#openstack@Freenode

### Ressources

-   Actualités :
    -   Blog officiel : <https://www.openstack.org/blog/>
    -   Planet : <http://planet.openstack.org/>
    -   Superuser : <http://superuser.openstack.org/>
-   Ressources commerciales : <https://www.openstack.org/marketplace/> entre autres
-   Job board : <https://www.openstack.org/community/jobs/>

### User Survey

-   Sondage réalisé régulièrement par la Fondation (tous les 6 mois)
-   Auprès des déployeurs et utilisateurs
-   Données exploitables : <https://www.openstack.org/analytics>

### Certification Certified OpenStack Administrator (COA)

-   La seule certification :
    - Validée par la Fondation OpenStack
    - Non liée à une entreprise particulière
-   Contenu :
    -   Essentiellement orientée *utilisateur* de cloud OpenStack
    -   <https://www.openstack.org/coa/requirements/>
-   Aspects pratiques :
    -   Examen pratique, passage à distance, durée : 2,5 heures
    -   Coût : $300 (deux passages possibles)
-   Ressources
    - <https://www.openstack.org/coa/>
    - Tips : <https://www.openstack.org/coa/tips/>
    - Handbook : <http://www.openstack.org/coa/handbook>
    - Exercices (non-officiels) : <https://github.com/AJNOURI/COA>

### Ressources - Communauté francophone et association

![Logo OpenStack-fr](images/openstackfr.png){height=50px}

-   <https://openstack.fr/> - <https://asso.openstack.fr/>
-   Meetups : Paris, Lyon, Toulouse, Montréal, etc.
-   OpenStack Days France (Paris) : <https://openstackdayfrance.fr/>
-   Présence à des événements tels que *Paris Open Source Summit*
-   Canaux de communication :
    -   openstack-fr@lists.openstack.org
    -   \#openstack-fr@Freenode

