# Tirer partie de l’IaaS

### Deux visions

Une fois un cloud IaaS en place, deux optiques possibles :

-   Garder les mêmes pratiques tout en profitant du self service et de l’agilité de la solution pour des besoins test/dev
-   Faire évoluer ses pratiques, tant côté applicatif que système “Pets vs Cattle”

### Sinon ?

Faire tourner des applications *legacy* dans le cloud est une mauvaise
idée :

-   Interruptions de service
-   Pertes de données
-   Incompréhensions “le cloud ça marche pas”

# Côté applications

### Adapter ou penser ses applications “cloud ready”
Cf. les design tenets du projet OpenStack et Twelve-Factor <http://12factor.net/>

-   Architecture distribuée plutôt que monolithique
    -   Facilite le passage à l’échelle
    -   Limite les domaines de *failure*
-   Couplage faible entre les composants
-   Bus de messages pour les communications inter-composants
-   Stateless : permet de multiplier les routes d’accès à l’application
-   Dynamicité : l’application doit s’adapter à son environnement et se reconfigurer lorsque nécessaire
-   Permettre le déploiement et l’exploitation par des outils d’automatisation
-   Limiter autant que possible les dépendances à du matériel ou du logiciel spécifique qui pourrait ne pas fonctionner dans un cloud
-   Tolérance aux pannes (*fault tolerance*) intégrée
-   Ne pas stocker les données en local, mais plutôt :
    -   Base de données
    -   Stockage objet
-   Utiliser des outils standards de journalisation

# Côté système

### Adopter une philosophie DevOps
-   Infrastructure as Code
-   Scale out plutôt que scale up (horizontalement plutôt que verticalement)
-   HA niveau application plutôt qu’infrastructure
-   Automatisation, automatisation, automatisation
-   Tests

### Monitoring et backup

Monitoring

-   Prendre en compte le cycle de vie des instances
-   Monitorer le service plus que le serveur

Backuper, quoi ?

-   Être capable de recréer ses instances (et le reste de son infrastructure)
-   Données (applicatives, logs) : block, objet

### Utiliser des images cloud

Une image cloud c’est :

-   Une image disque contenant un OS déjà installé
-   Une image qui peut être instanciée en n machines sans erreur
-   Un OS sachant parler à l’API de metadata du cloud (cloud-init)

Détails : <http://docs.openstack.org/image-guide/content/ch_openstack_images.html>\
La plupart des distributions fournissent aujourd’hui des images cloud.

### Cirros

-   Cirros est l’image cloud par excellence
-   OS minimaliste
-   Contient cloud-init

<https://launchpad.net/cirros>

### Cloud-init

-   Cloud-init est un moyen de tirer partie de l’API de metadata, et notamment des user data
-   L’outil est intégré par défaut dans la plupart des images cloud
-   À partir des user data, cloud-init effectue les opérations de personnalisation de l’instance
-   cloud-config est un format possible de user data

### Exemple cloud-config

    #cloud-config
    mounts:
     - [ xvdc, /var/www ]
    packages:
     - apache2
     - htop

### Comment gérer ses images ?

-   Utilisation d’images génériques et personnalisation à l’instanciation
-   Création d’images intermédiaires et/ou totalement personnalisées :
    *Golden images*
    -   libguestfs, virt-builder, virt-sysprep
    -   diskimage-builder (TripleO)
    -   Packer
    -   solution “maison”

### Configurer et orchestrer ses instances

-   Outils de gestion de configuration (les mêmes qui permettent de déployer OpenStack)
-   Juju

