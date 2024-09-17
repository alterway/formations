

# Présentation de Docker

### Historique de Docker

- 2010 : Création de dotCloud, une plateforme PaaS, par Solomon Hykes et Francois-Xavier Bourlet
- 2013 :
    - Rebaptisation de dotCloud en Docker
    - Open-source de Docker Engine, une technologie de conteneurisation
    - Levée de fonds de 15 millions de dollars auprès de Greylock Partners
- 2014 :
    - Lancement de Docker Hub, un registre de conteneurs
    - Levée de fonds de 40 millions de dollars auprès de Sequoia Capital
- 2015 :
    - Lancement de Docker Swarm, un outil d'orchestration de conteneurs
    - Levée de fonds de 95 millions de dollars auprès d'investisseurs tels que Insight Venture Partners et Coatue Management
- 2016 : Lancement de Docker for Mac et Docker for Windows
- 2017 :
    - Lancement de Docker Enterprise Edition
    - Levée de fonds de 75 millions de dollars auprès de Temasek et d'autres investisseurs
    - 2019 : Docker annonce la vente de sa plateforme d'entreprise à Mirantis en novembre
4

### Concepts clés de Docker

- Conteneurisation
    - Technologie permettant d'isoler des applications et leurs dépendances dans des conteneurs légers et portables
    - Les conteneurs partagent le noyau de l'hôte, mais ont leur propre espace de noms et leur propre système de fichiers
- Images Docker
    - Modèles utilisés pour créer des conteneurs
    - Composées de couches immuables, empilées les unes sur les autres
    - Peuvent être créées à partir d'un Dockerfile, qui contient les instructions de construction de l'image
- Docker Engine
    - Moteur de conteneurisation de Docker
    - Permet de créer, d'exécuter, d'arrêter et de supprimer des conteneurs
    - Prend en charge les images Docker et les registres d'images
- Docker Hub
    - Registre de conteneurs Docker hébergé dans le cloud
    - Permet de stocker, de partager et de distribuer des images Docker
    - Propose des images Docker officielles pour de nombreuses applications courantes
- Docker Compose
    - Outil permettant de définir et d'exécuter des applications multi-conteneurs
    - Utilise un fichier YAML pour décrire les services, les réseaux et les volumes nécessaires à l'application
    - Permet de démarrer, d'arrêter et de gérer l'ensemble de l'application en une seule commande


### Utilité de Docker

- Déploiement d'applications
    - Docker permet de créer des conteneurs légers et portables pour les applications
    - Les conteneurs peuvent être déployés sur n'importe quelle infrastructure prenant en charge - Docker, ce qui facilite la mise à l'échelle et la gestion des applications
    - Les conteneurs peuvent être facilement mis à jour, remplacés ou supprimés en fonction des besoins de l'application
- Création d'environnements de développement isolés
    - Docker permet de créer des environnements de développement isolés pour les applications
    - Les développeurs peuvent travailler sur des conteneurs séparés, ce qui évite les conflits entre les dépendances et les configurations des applications
    - Les conteneurs peuvent être facilement partagés entre les membres de l'équipe, ce qui facilite la collaboration et le débogage
- Création d'environnements de test et de préproduction
    - Docker permet de créer des environnements de test et de préproduction identiques à l'environnement de production
    - Les tests peuvent être effectués dans des conteneurs isolés, ce qui évite les interférences avec l'environnement de production
    - Les conteneurs peuvent être facilement supprimés et recréés en fonction des besoins des tests
- Migration d'applications
    - Docker permet de migrer des applications existantes vers des conteneurs
    - Les conteneurs peuvent être déployés sur n'importe quelle infrastructure prenant en charge Docker, ce qui facilite la migration vers le cloud ou vers une nouvelle infrastructure
    - Les conteneurs peuvent être facilement mis à jour ou remplacés en fonction des besoins de l'application


### Rappels sur la virtualisation et les conteneurs


### Virtualisation

- Définition
    - La virtualisation est une technologie qui permet de faire fonctionner plusieurs systèmes d'exploitation sur une seule machine physique
    - Chaque système d'exploitation s'exécute dans une machine virtuelle, qui est une simulation logicielle d'une machine physique
- Fonctionnement
    - Un logiciel de virtualisation, tel que VMware ou VirtualBox, crée une couche d'abstraction entre le matériel physique et les machines virtuelles
    - Les machines virtuelles peuvent être configurées avec des ressources virtuelles, telles que la mémoire, le stockage et le processeur, qui sont allouées à partir des ressources physiques de la machine hôte
    -Les machines virtuelles peuvent être démarrées, arrêtées et gérées indépendamment les unes des autres
- Utilité
    - La virtualisation permet de consolider plusieurs serveurs physiques en un seul serveur, ce qui réduit les coûts matériels et énergétiques
    - La virtualisation permet de créer des environnements isolés pour les applications, ce qui améliore la sécurité et la stabilité
    - La virtualisation permet de créer des environnements de test et de développement identiques à l'environnement de production, ce qui facilite la collaboration et le débogage
- Docker et la virtualisation
    - Docker utilise une technologie de virtualisation légère appelée conteneurisation
    - Les conteneurs Docker partagent le noyau de l'hôte, ce qui les rend plus légers et plus rapides que les machines virtuelles
    - Les conteneurs Docker peuvent être déployés sur n'importe quelle infrastructure prenant en charge Docker, ce qui facilite la portabilité et la mise à l'échelle des applications


### Virtualisation

Image

### Conteneurs

- Définition
    - Les conteneurs sont une technologie de virtualisation légère qui permet d'isoler des applications et leurs dépendances dans des environnements séparés
    - Les conteneurs partagent le noyau de l'hôte, mais ont leur propre espace de noms et leur propre système de fichiers
- Comparaison avec la virtualisation traditionnelle
    - Les conteneurs sont plus légers que les machines virtuelles, car ils ne nécessitent pas de système d'exploitation invité complet
    - Les conteneurs sont plus rapides à démarrer et à arrêter que les machines virtuelles, car ils n'ont pas besoin de démarrer un système d'exploitation complet
    - Les conteneurs sont plus faciles à gérer que les machines virtuelles, car ils peuvent être créés, supprimés et mis à jour plus rapidement
- Avantages
    - Légèreté : les conteneurs sont plus légers que les machines virtuelles, ce qui réduit les coûts d'infrastructure et améliore les performances
    - Portabilité : les conteneurs peuvent être déployés sur n'importe quelle infrastructure prenant en charge Docker, ce qui facilite la portabilité et la mise à l'échelle des applications
    - Isolation : les conteneurs offrent une isolation des applications et des dépendances, ce qui améliore la sécurité et la stabilité
    - Efficacité : les conteneurs permettent de maximiser l'utilisation des ressources système en partageant le noyau de l'hôte et en allouant dynamiquement les ressources aux conteneurs en fonction des besoins
- Docker et les conteneurs
    - Docker est une plateforme de conteneurisation open-source qui permet de créer, de déployer et de gérer des conteneurs
    - Docker utilise les fonctionnalités de virtualisation du noyau Linux pour créer des conteneurs légers et portables
    - Docker fournit des outils pour automatiser la création, le déploiement et la gestion des conteneurs, ce qui facilite le développement et le déploiement d'applications

### Conteneurs

Image

### Encapsulation :Linux Kernel Namespaces

Les Linux kernel namespaces sont une fonctionnalité clé de l'isolation des conteneurs Docker. Les namespaces permettent de créer des espaces d'isolation pour les processus, les réseaux, les systèmes de fichiers, les identifiants utilisateur et les groupes, et d'autres ressources du système.

Types de namespaces

Il existe plusieurs types de Linux kernel namespaces, chacun fournissant un niveau d'isolation différent :

- PID namespace : isole les processus en leur attribuant des identifiants uniques dans chaque namespace. Cela permet de créer des conteneurs avec leur propre arborescence de processus.
- Network namespace : isole les réseaux en leur attribuant des interfaces réseau, des tables de routage et des règles de pare-feu uniques. Cela permet de créer des conteneurs avec leur propre pile réseau.
- Mount namespace : isole les systèmes de fichiers en leur attribuant des points de montage uniques. Cela permet de créer des conteneurs avec leur propre vue du système de fichiers.
- UTS namespace : isole les noms d'hôte et de domaine en leur attribuant des valeurs uniques. Cela permet de créer des conteneurs avec leur propre nom d'hôte.
- IPC namespace : isole les mécanismes de communication inter-processus (IPC) tels que les sémaphores, les files d'attente de messages et la mémoire partagée. Cela permet de créer des conteneurs avec leur propre espace IPC.
- User namespace : isole les identifiants utilisateur et les groupes en leur attribuant des valeurs uniques. Cela permet de créer des conteneurs avec leur propre espace utilisateur et groupe.



### Linux Kernel PID Namespaces


Image

### Architecture de Docker


### Architecture de Docker Engine

- Docker Engine
    - Docker Engine est le moteur de conteneurisation de Docker
    - Docker Engine est responsable de la création, de la gestion et de l'exécution des conteneurs
Architecture de Docker Engine
    - Docker Engine est composé de trois composants principaux : le démon Docker, l'API REST et le client Docker
    - Démon Docker
    - Le démon Docker est un processus en arrière-plan qui gère les conteneurs, les images et les réseaux
    - Le démon Docker est responsable de la création, du démarrage, de l'arrêt et de la suppression des conteneurs
    - Le démon Docker communique avec le noyau Linux pour gérer les conteneurs et les ressources système
- API REST
    - L'API REST de Docker permet aux clients Docker de communiquer avec le démon Docker
    - L'API REST de Docker est utilisée pour créer, gérer et surveiller les conteneurs, les images et les réseaux
    - L'API REST de Docker est accessible via le réseau, ce qui permet de gérer Docker à distance
- Client Docker
    - Le client Docker est un outil en ligne de commande qui permet de communiquer avec le démon Docker via l'API REST
    - Le client Docker permet de créer, de gérer et de surveiller les conteneurs, les images et les réseaux
    - Le client Docker peut être installé sur n'importe quel système prenant en charge Docker, ce qui permet de gérer Docker à distance


### Docker Client

- Docker Client
    - Docker Client est un outil en ligne de commande qui permet aux utilisateurs d'interagir avec le moteur Docker
    - Docker Client envoie des commandes à l'API REST de Docker, qui les transmet au démon Docker pour exécution

- Commandes Docker
    - Les commandes Docker sont utilisées pour créer, gérer et surveiller les conteneurs, les images et les réseaux
    - Les commandes Docker sont exécutées à l'aide de la syntaxe suivante : docker [command] [options] [arguments]
    - Exemples de commandes Docker : docker run, docker ps, docker stop, docker rm, docker pull, docker build, etc.
- Installation de Docker Client
    - Docker Client peut être installé sur n'importe quel système prenant en charge Docker, y compris les systèmes d'exploitation Windows, Mac et Linux
    - Docker Client peut être installé à l'aide d'un package manager, tel que apt, yum ou brew, ou en téléchargeant le package d'installation à partir du site web de Docker
- Utilisation de Docker Client
    - Docker Client peut être utilisé pour gérer les conteneurs, les images et les réseaux sur le système local ou sur un système distant prenant en charge Docker
    - Docker Client peut être utilisé pour automatiser la création, le déploiement et la gestion des conteneurs à l'aide de scripts ou d'outils d'orchestration, tels que Docker Compose ou Kubernetes


### IMAGES DOCKER


### Compréhension des images Docker

- Définition
    - Les images Docker sont des modèles utilisés pour créer des conteneurs Docker
    - Les images Docker contiennent toutes les dépendances nécessaires à l'exécution d'une application, telles que le code, les bibliothèques, les outils et les paramètres de configuration
- Structure
    - Les images Docker sont composées de couches imbriquées, chaque couche représentant une modification apportée à l'image de base
    - Les couches sont empilées les unes sur les autres pour former l'image finale
    - Les couches sont stockées dans un cache local, ce qui permet de réutiliser les couches existantes pour créer de nouvelles images plus rapidement
- Utilisation
    - Les images Docker peuvent être utilisées pour créer des conteneurs Docker à l'aide de la commande docker run
    - Les images Docker peuvent être téléchargées à partir de registres publics ou privés, tels que Docker Hub ou Amazon ECR
    - Les images Docker peuvent être créées à l'aide de la commande docker build, qui construit une nouvelle image à partir d'un fichier Dockerfile
- Dockerfile
    - Un Dockerfile est un fichier de script utilisé pour automatiser la création d'images Docker
    - Un Dockerfile contient des instructions pour installer des dépendances, copier des fichiers, définir des variables d'environnement et configurer des paramètres de conteneur
    - Un Dockerfile peut être utilisé pour créer des images personnalisées à partir d'images de base ou pour créer des images à partir de zéro
18

Les mécanismes de copy-on-write de Docker
Docker utilise des mécanismes de copy-on-write pour optimiser l'utilisation de l'espace disque et de la mémoire.
Lorsqu'un conteneur Docker est lancé, il utilise une image de base comme couche de base en lecture seule.
Toutes les modifications apportées au système de fichiers du conteneur sont stockées dans une couche de différence en lecture-écriture, qui est superposée à la couche de base.
Cette couche de différence est spécifique à chaque conteneur et est créée en utilisant le mécanisme de copy-on-write.
Lorsqu'un processus dans le conteneur écrit sur le système de fichiers, les données sont écrites dans la couche de différence. Si les données existent déjà dans la couche de base, elles sont copiées dans la couche de différence avant d'être modifiées.
Cela permet de partager les données communes entre plusieurs conteneurs et de réduire l'utilisation de l'espace disque et de la mémoire.
Lorsqu'un conteneur est supprimé, sa couche de différence est également supprimée, ce qui libère de l'espace disque.

19

 Les mécanismes de copy-on-write de Docker
20

Manipulation des images Docker - Introduction
Les images Docker sont des modèles utilisés pour créer des conteneurs
Les images Docker peuvent être téléchargées à partir de registres publics ou privés, tels que Docker Hub, Amazon ECR, Harbor, Azure ACR, Github, Gitlab, registry2…
Les images Docker peuvent être créées à l'aide de la commande docker build, qui construit une nouvelle image à partir d'un fichier Dockerfile
Les images Docker peuvent être manipulées à l'aide de diverses commandes de base, telles que docker pull, docker images et docker rmi
21

Manipulation des images Docker - Téléchargement d'images
La commande docker pull est utilisée pour télécharger une image Docker à partir d'un registre
Exemple : docker pull nginx télécharge l'image Docker officielle de Nginx à partir du registre Docker Hub
L'option --no-cache peut être utilisée pour ne pas utiliser le cache local lors du téléchargement d'une image
Les images Docker téléchargées sont stockées dans le cache local pour une utilisation ultérieure
22

Manipulation des images Docker - Affichage des images
La commande docker images (docker image ls) est utilisée pour afficher la liste des images Docker disponibles sur le système local
La sortie de la commande docker images affiche les informations suivantes pour chaque image : nom, tag, ID d'image, date de création et taille
L'option -a peut être utilisée pour afficher toutes les images, y compris les images intermédiaires utilisées lors de la construction d'une image
L'option --digests peut être utilisée pour afficher les digests d'image, qui sont des sommes de contrôle cryptographiques uniques pour chaque image

23

Manipulation des images Docker - Suppression des images
La commande docker rmi est utilisée pour supprimer une image Docker du système local
Exemple : docker rmi nginx supprime l'image Docker Nginx du système local
L'option -f peut être utilisée pour forcer la suppression d'une image Docker, même si elle est utilisée par un conteneur
L'option -a peut être utilisée pour supprimer toutes les images Docker du système local
Les images Docker inutilisées doivent être régulièrement supprimées pour libérer de l'espace disque
24

Manipulation des images Docker - Création d'images
La commande docker build est utilisée pour créer une nouvelle image Docker à partir d'un fichier Dockerfile
Le fichier Dockerfile contient des instructions pour installer des dépendances, copier des fichiers, définir des variables d'environnement et configurer des paramètres de conteneur
Exemple : docker build -t mon-image . construit une nouvelle image Docker à partir du fichier Dockerfile dans le répertoire courant et l'étiquette avec le nom "mon-image"
Les images Docker personnalisées peuvent être téléchargées vers des registres publics ou privés pour être partagées avec d'autres utilisateurs

25

DOCKERFILE
26

Compréhension du Dockerfile - Introduction
Un Dockerfile est un fichier de script utilisé pour automatiser la création d'images Docker
Le Dockerfile contient des instructions pour installer des dépendances, copier des fichiers, définir des variables d'environnement et configurer des paramètres de conteneur
Les instructions du Dockerfile sont exécutées dans l'ordre dans lequel elles apparaissent dans le fichier
Les images Docker créées à partir d'un Dockerfile sont reproductibles et peuvent être partagées avec d'autres utilisateurs
27

Compréhension du Dockerfile - Instructions de base
FROM : définit l'image de base à utiliser pour créer l'image Docker
RUN : exécute une commande dans le conteneur et crée une nouvelle couche dans l'image
COPY : copie des fichiers ou des répertoires du système hôte vers le conteneur
ADD : similaire à COPY, mais avec des fonctionnalités supplémentaires telles que le dépaquetage d'archives et le téléchargement de fichiers à partir d'URL
WORKDIR : définit le répertoire de travail actuel dans le conteneur
ENV : définit des variables d'environnement dans le conteneur
EXPOSE : spécifie les ports réseau auxquels le conteneur écoutera
CMD : définit la commande par défaut à exécuter lorsque le conteneur démarre
ENTRYPOINT : spécifie la commande à exécuter lorsque le conteneur est lancé.
28

Exemple Dockerfile
29
# Utiliser une image de base officielle Ubuntu
FROM ubuntu:20.04

# Mettre à jour les paquets et installer Apache et PHP
RUN apt-get update && apt-get install -y \
    apache2 \
    php \
    libapache2-mod-php \
    && rm -rf /var/lib/apt/lists/*

# Copier le fichier de configuration Apache dans le conteneur
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Ajouter un fichier index.php dans le répertoire racine du serveur web
ADD index.php /var/www/html/

# Définir le répertoire de travail actuel dans le conteneur
WORKDIR /var/www/html

# Définir des variables d'environnement dans le conteneur
ENV APPLICATION_ENV production
ENV LOG_LEVEL info

# Exposer le port 80 pour permettre au conteneur d'écouter les requêtes HTTP
EXPOSE 80

# Définir la commande par défaut à exécuter lorsque le conteneur démarre
CMD ["apache2ctl", "-D", "FOREGROUND"]

# Spécifier la commande à exécuter lorsque le conteneur est lancé
ENTRYPOINT ["/entrypoint.sh"]

CMD vs ENTRYPOINT dans un Dockerfile
Dans un Dockerfile, les commandes CMD et ENTRYPOINT sont utilisées pour spécifier la commande à exécuter lorsque le conteneur est lancé. Bien qu'elles puissent sembler similaires, elles ont des différences importantes dans leur fonctionnement et leur utilisation.
CMD
La commande CMD est utilisée pour spécifier la commande par défaut à exécuter lorsque le conteneur est lancé. Si une commande est spécifiée dans docker run, elle remplace la commande CMD. Si aucune commande n'est spécifiée, la commande CMD est utilisée.
Syntaxe : CMD ["executable","param1","param2"] ou CMD command param1 param2
Exemple : CMD ["apachectl", "-DFOREGROUND"]


30

CMD vs ENTRYPOINT dans un Dockerfile
ENTRYPOINT
La commande ENTRYPOINT est utilisée pour spécifier la commande à exécuter lorsque le conteneur est lancé. Contrairement à la commande CMD, la commande ENTRYPOINT ne peut pas être remplacée par une commande docker run. Si des arguments sont spécifiés dans docker run, ils sont passés à la commande ENTRYPOINT.
Syntaxe : ENTRYPOINT ["executable","param1","param2"] ou ENTRYPOINT command param1 param2
Exemple : ENTRYPOINT ["apachectl", "-DFOREGROUND"]
CMD et ENTRYPOINT ensemble
La commande CMD peut être utilisée en conjonction avec ENTRYPOINT pour spécifier les arguments par défaut de la commande ENTRYPOINT. Si une commande est spécifiée dans docker run, elle remplace la commande CMD, mais pas la commande ENTRYPOINT.


31

Compréhension du Dockerfile - Bonnes pratiques
Utiliser une image de base officielle et à jour pour créer l'image Docker
Minimiser le nombre de couches dans l'image Docker en regroupant les commandes RUN autant que possible
Éviter d'installer des dépendances inutiles dans l'image Docker
Utiliser des variables d'environnement pour configurer le conteneur plutôt que de coder en dur les valeurs dans le Dockerfile
Utiliser des tags pour identifier les versions de l'image Docker et faciliter la gestion des mises à jour
32

DOCKERFILE - Bonne Pratiques 
33

Bonnes pratiques pour écrire un Dockerfile - Introduction
Les bonnes pratiques pour écrire un Dockerfile peuvent aider à créer des images Docker plus petites, plus rapides et plus fiables
Les bonnes pratiques peuvent également faciliter la maintenance et la collaboration sur les images Docker
Les bonnes pratiques pour écrire un Dockerfile comprennent des recommandations sur l'utilisation des instructions, la gestion des dépendances, la sécurité et la performance
34

Bonnes pratiques Dockerfile - Utilisation des instructions
Utiliser une image de base officielle et à jour pour créer l'image Docker
Minimiser le nombre de couches dans l'image Docker en regroupant les commandes RUN autant que possible
Utiliser l'instruction COPY plutôt que ADD pour copier des fichiers et des répertoires dans le conteneur
Utiliser l'instruction WORKDIR pour définir le répertoire de travail actuel dans le conteneur
Utiliser l'instruction ENV pour définir des variables d'environnement dans le conteneur
Utiliser l'instruction EXPOSE pour spécifier les ports réseau auxquels le conteneur écoutera
Utiliser l'instruction CMD pour définir la commande par défaut à exécuter lorsque le conteneur démarre
Éviter d'utiliser l'instruction ENTRYPOINT pour définir la commande par défaut à exécuter lorsque le conteneur démarre, sauf si nécessaire

35

Bonnes pratiques Dockerfile - Gestion des dépendances
Installer les dépendances nécessaires à l'exécution de l'application dans le conteneur
Éviter d'installer des dépendances inutiles dans le conteneur
Utiliser des gestionnaires de paquets pour installer les dépendances, tels que apt-get ou yum pour les systèmes Linux, ou pip pour Python
Mettre à jour les gestionnaires de paquets avant d'installer les dépendances pour s'assurer que les dernières versions sont utilisées
Utiliser des versions spécifiques des dépendances pour éviter les problèmes de compatibilité
Utiliser des caches pour accélérer l'installation des dépendances lors de la construction de l'image
36

Bonnes pratiques Dockerfile - Sécurité
Utiliser des images de base officielles et à jour pour créer l'image Docker
Utiliser des utilisateurs non-root dans le conteneur pour minimiser les risques de sécurité
Désactiver les services inutiles dans le conteneur pour minimiser la surface d'attaque
Utiliser des secrets pour stocker les informations sensibles, telles que les mots de passe et les clés d'API, plutôt que de les coder en dur dans le Dockerfile
Utiliser des analyses de vulnérabilité pour détecter les failles de sécurité dans l'image Docker
37

Bonnes pratiques Dockerfile - Performance
Minimiser la taille de l'image Docker en supprimant les fichiers inutiles et en compressant les couches
Utiliser des tags pour identifier les versions de l'image Docker et faciliter la gestion des mises à jour
Utiliser des builds multi-étapes pour séparer les dépendances de construction des dépendances d'exécution
Utiliser des caches pour accélérer la construction de l'image Docker
Utiliser des conteneurs éphémères pour tester les modifications apportées à l'image Docker avant de les publier
38

Bonnes pratiques Dockerfile - Exemples
FROM python:3.9-slim-buster

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

CMD [ "python", "app.py" ]
FROM node:14-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 8080

CMD [ "npm", "start" ]
39

Les espaces de noms des images Docker
Les images Docker existent dans l'un des trois espaces de noms suivants : root, utilisateur/organisation et registre.
L'espace de noms root contient les images officielles fournies par Docker et les principaux éditeurs de logiciels. Ces images n'ont pas de préfixe et sont généralement considérées comme fiables et maintenues.
root:
Ubuntu
Nginx
Debian
ms1 (locale)
utilisateur/organisation
herveleclerc/ms1
alterway/ms2
registry
docker.io/library/nginx
reg.alterway.fr/devops/php
ghcr.io/herveleclerc/ms1
ghcr.io/alterway/ms2

40

Comment gérer et utiliser les versions des images Docker
Qu'est-ce qu'un tag dans Docker ?
Un tag est une chaîne de caractères ajoutée à une image Docker pour identifier une version spécifique de l'image
Le tag est séparé du nom de l'image par deux points (:)
Si aucun tag n'est spécifié, l'image est taguée par défaut avec la chaîne "latest"
Comment ajouter un tag à une image Docker ?
Utiliser la commande "docker tag" pour ajouter un tag à une image Docker
La syntaxe de la commande est la suivante :
docker tag nom-image:tag-source nom-image:tag-cible
exemple
docker tag mon-image:1.0 mon-image:stable

41

Comment gérer et utiliser les versions des images Docker
Comment utiliser un tag d'image Docker ?
Utiliser la commande "docker run" pour créer un conteneur à partir d'une image Docker spécifique
Spécifier le nom de l'image et le tag pour sélectionner la version souhaitée de l'image
Exemple :
docker run -d --name mon-conteneur mon-image:stable
Comment supprimer un tag d'image Docker ?
Utiliser la commande "docker rmi" pour supprimer un tag d'image Docker
Spécifier le nom de l'image et le tag pour supprimer la version correspondante de l'image
Exemple :
docker rmi mon-image:1.0
42

Dockerfile avancé - ONBUILD
L'instruction ONBUILD ajoute à l'image une instruction de déclenchement à exécuter ultérieurement lorsque l'image sera utilisée comme base pour une autre build. Le déclencheur sera exécuté dans le contexte de la construction en aval comme s'il avait été inséré immédiatement après l'instruction FROM dans le Dockerfile en aval.
Lorsque l'instruction ONBUILD est rencontrée dans le Dockerfile, l'instruction est ajoutée pour être exécutée plus tard. On peut inspecter les commandes dans le fichier manifeste d'image sous la clé ONBuild. Toutes les commandes enregistrées dans ONBUILD seront exécutées dans l'ordre dans lequel elles sont apparues dans Dockerfile.

CONSEIL : le chaînage d'instructions ONBUILD à l'aide d'ONBUILD ONBUILD n'est pas autorisé. 
L'instruction ONBUILD ne peut pas déclencher les instructions FROM ou MAINTAINER.
43

Dockerfile avancé - ONBUILD - Exemple
44
FROM nginx:1.16-alpine
LABEL Author="Herve Leclerc"
WORKDIR /usr/share/nginx/html
ONBUILD COPY index.html .

docker build -t herveleclerc/nginx:1.16-alpine-onbuild .
FROM herveleclerc/nginx:1.16-alpine-onbuild

cat index.html
<h1>Hello Hervé !</h1>


cat index.html
<h1>Hello Hervé !</h1>


docker build -t test .
docker run -ti --rm test cat /usr/share/nginx/html/index.html

<h1>Hello Hervé !</h1>


ls 
Dockerfile  index.html
ls 
Dockerfile

Fonctionnalités avancées de build d'images Docker avec les multi-stages
45

Multi-stages - Introduction
Les builds multi-stages permettent de diviser le processus de construction d'une image Docker en plusieurs étapes distinctes
Chaque étape est exécutée dans un conteneur séparé, ce qui permet de séparer les dépendances de construction des dépendances d'exécution
Les builds multi-stages peuvent être utilisés pour réduire la taille de l'image finale en supprimant les fichiers inutiles et en compressant les couches
Les builds multi-stages peuvent également être utilisés pour créer des images Docker pour plusieurs architectures ou systèmes d'exploitation
46

Multi-stages - Syntaxe
La syntaxe pour définir un build multi-stages dans un Dockerfile est la suivante :
FROM image1 as stage1
...

FROM image2 as stage2
...

FROM image3
...
Chaque étape est définie à l'aide de l'instruction FROM, suivie de l'image de base à utiliser pour cette étape
Le nom de l'étape peut être défini à l'aide du mot-clé as
Les fichiers et les répertoires peuvent être copiés d'une étape à l'autre à l'aide de l'instruction COPY --from=stage
47

Multi-stages - Séparation des dépendances
Les builds multi-stages peuvent être utilisés pour séparer les dépendances de construction des dépendances d'exécution
Les dépendances de construction sont les outils et les bibliothèques nécessaires pour construire l'application, mais qui ne sont pas nécessaires pour l'exécuter
Les dépendances d'exécution sont les bibliothèques et les fichiers nécessaires pour exécuter l'application
En séparant les dépendances de construction des dépendances d'exécution, il est possible de réduire la taille de l'image finale et d'améliorer la sécurité
48

Multi-stages - Réduction de la taille de l'image

Les builds multi-stages peuvent être utilisés pour réduire la taille de l'image finale en supprimant les fichiers inutiles et en compressant les couches
Les fichiers inutiles peuvent être supprimés à l'aide de l'instruction RUN avec la commande rm
Les couches peuvent être compressées à l'aide de l'instruction MULTISTAGE avec l'option --squash
La compression des couches peut réduire considérablement la taille de l'image finale, mais peut également augmenter le temps de construction
49

Multi-stages - Création d'images pour plusieurs architectures

Les builds multi-stages peuvent être utilisés pour créer des images Docker pour plusieurs architectures ou systèmes d'exploitation
Les images peuvent être créées pour différentes architectures en utilisant des images de base différentes pour chaque architecture
Les fichiers et les répertoires peuvent être copiés d'une étape à l'autre en utilisant l'instruction COPY --from=stage
Les images peuvent être étiquetées pour différentes architectures en utilisant l'instruction docker buildx build --platform
50

Multi-stages - Exemple
# Étape 1 : Construction de l'application
FROM golang:1.16 as builder

WORKDIR /app

COPY . .

RUN go build -o main .

# Étape 2 : Création de l'image finale
FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/main /app/

CMD [ "/app/main" ]
La première étape utilise l'image golang:1.16 pour construire l'application à l'aide de la commande go build. L'application est construite dans le répertoire /app.
La deuxième étape utilise l'image alpine:latest pour créer l'image finale. L'application compilée est copiée depuis l'étape de construction à l'aide de la commande COPY --from=builder. La commande CMD est utilisée pour définir la commande par défaut à exécuter lorsque le conteneur démarre.
51

Multi-stages - Exemple
FROM alpine:3.5
RUN apk update && \
apk add --update alpine-sdk
RUN mkdir /app
WORKDIR /app
ADD hello.c /app
RUN mkdir bin
RUN gcc -Wall hello.c -o bin/hello
CMD /app/bin/hello
52
# Full SDK version (built and discarded)
FROM alpine:3.5 AS build
RUN apk update && \
    apk add --update alpine-sdk
RUN mkdir /app
WORKDIR /app
ADD hello.c /app
RUN mkdir bin
RUN gcc -Wall hello.c -o bin/hello
# Lightweight image returned as final product
FROM alpine:3.5
COPY --from=build /app/bin/hello /app/hello
CMD /app/hello

BUILDKIT - Compilateur Docker Optimisé pour la Vitesse

Introduction
Un nouveau backend pour le processus de compilation de Docker.
Activez via export DOCKER_BUILDKIT=1.
Caractéristiques Principales
Paralléliser les compilations multi-étapes pour une création plus rapide et efficace d'images de conteneurs.
Permet des frontends personnalisés, offrant flexibilité dans le processus de compilation.
Amélioration des Performances
Offre une accélération significative de la vitesse de compilation, allant de 2x à 9x.
Compatibilité
Actuellement pris en charge sur les plateformes Linux à partir de la version Docker 18.09.0-ee.

53

Containers Docker
54

Compréhension des conteneurs Docker

Définition :
Un conteneur Docker est une unité d'exécution légère et autonome qui contient tout ce dont une application a besoin pour fonctionner, y compris le code, les bibliothèques, les outils et les paramètres de configuration.
Les conteneurs Docker sont isolés les uns des autres et du système hôte, ce qui permet de déployer plusieurs applications sur un seul hôte sans interférence.
Cycle de vie :
Les conteneurs Docker ont un cycle de vie qui comprend les étapes suivantes : création, démarrage, arrêt et suppression.
Les conteneurs peuvent être créés à partir d'images Docker à l'aide de la commande docker run.
Les conteneurs peuvent être démarrés et arrêtés à l'aide des commandes docker start et docker stop.
Les conteneurs peuvent être supprimés à l'aide de la commande docker rm.
Utilisation :
Les conteneurs Docker peuvent être utilisés pour déployer des applications dans différents environnements, tels que le développement, le test et la production.
Les conteneurs Docker peuvent être utilisés pour créer des environnements de développement isolés pour les développeurs.
Les conteneurs Docker peuvent être utilisés pour créer des environnements de test standardisés pour les tests d'intégration et de performance.
Les conteneurs Docker peuvent être utilisés pour créer des environnements de production évolutifs et résilients.
55

Compréhension des conteneurs Docker

+---------------------+
| Conteneur arrêté    |
+---------------------+
          |  docker start
          |
          v
+---------------------+
| Conteneur en cours  |
| d'exécution         |
+---------------------+
          |  docker pause
          |
          v
+---------------------+
| Conteneur en pause  |
+---------------------+
          |  docker unpause
          |
          v
+---------------------+
| Conteneur en cours  |
| d'exécution         |
+---------------------+
          |  docker stop
          |
          v
+---------------------+
| Conteneur arrêté    |
+---------------------+
          |  docker rm
          |
          v
+---------------------+
| Conteneur supprimé  |
+---------------------+
Dans ce schéma, le cycle de vie d'un conteneur Docker est représenté avec les étapes suivantes :
Conteneur arrêté : le conteneur n'est pas en cours d'exécution.
Conteneur en cours d'exécution : le conteneur est en cours d'exécution et peut être utilisé pour exécuter une application.
Conteneur en pause : le conteneur est mis en pause, ce qui signifie que tous les processus en cours d'exécution dans le conteneur sont gelés. Le conteneur reste dans cet état jusqu'à ce qu'il soit dégelé à l'aide de la commande docker unpause.
Conteneur arrêté : le conteneur est arrêté à l'aide de la commande docker stop.
Conteneur supprimé : le conteneur est supprimé à l'aide de la commande docker rm
56

Manipulation des conteneurs Docker - Introduction

Les conteneurs Docker peuvent être manipulés à l'aide de commandes Docker en ligne de commande.
Les commandes Docker permettent de créer, démarrer, arrêter, supprimer et inspecter des conteneurs.
Les commandes Docker peuvent également être utilisées pour gérer les réseaux, les volumes et les images Docker.
57

Docker CLI - Commandes usuelles

docker run : crée et démarre un nouveau conteneur à partir d'une image Docker.
docker start : démarre un conteneur arrêté.
docker stop : arrête un conteneur en cours d'exécution.
docker rm : supprime un conteneur arrêté.
docker ps : affiche la liste des conteneurs en cours d'exécution.
docker ps -a : affiche la liste de tous les conteneurs, y compris ceux qui sont arrêtés.
docker logs : affiche les journaux d'un conteneur en cours d'exécution.
58

Docker CLI - Commandes avancées

docker exec : exécute une commande dans un conteneur en cours d'exécution.
docker cp : copie des fichiers entre le système hôte et un conteneur.
docker inspect : affiche des informations détaillées sur un conteneur, une image ou un réseau.
docker update : met à jour la configuration d'un conteneur en cours d'exécution.
docker pause : met en pause un conteneur en cours d'exécution.
docker unpause : reprend l'exécution d'un conteneur en pause.
docker kill : arrête brutalement un conteneur en cours d'exécution.
59

Docker CLI - Commandes de réseau

docker network create : créer un nouveau réseau.
docker network ls : affiche la liste des réseaux.
docker network inspect : affiche des informations détaillées sur un réseau.
docker network connect : connecte un conteneur à un réseau.
docker network disconnect : déconnecte un conteneur d'un réseau.
docker network rm : supprime un réseau.
60

Les Volumes Docker
61

Description des volumes Docker

Les volumes Docker permettent de stocker des données persistantes dans des conteneurs Docker.
Les volumes Docker sont des répertoires ou des fichiers du système hôte qui sont montés dans des conteneurs.
Les volumes Docker sont gérés par le moteur Docker et peuvent être partagés entre plusieurs conteneurs.
Les volumes Docker peuvent être créés, supprimés, inspectés et mis à jour à l'aide de commandes Docker.
3 Types de volumes:
Named : géré par Docker ; indépendant du système de fichiers ; identifiant spécifié par l'utilisateur
Anonymous : géré par Docker ; indépendant du système de fichiers ; identifiant généré aléatoirement
Host mounted : monter un chemin spécifique sur l'hôte ; gestion DIY (Do It Yourself)
62

Création de volumes Docker

Les volumes Docker peuvent être créés à l'aide de la commande docker volume create.
La commande docker volume create prend en option le nom du volume à créer.
Si aucun nom n'est spécifié, Docker génère automatiquement un nom pour le volume.
Exemple : docker volume create mon-volume

63

Inspection des volumes Docker

Les volumes Docker peuvent être inspectés à l'aide de la commande docker volume inspect.
La commande docker volume inspect affiche des informations détaillées sur le volume, telles que son nom, son chemin d'accès, son pilote et ses options de création.
Exemple : docker volume inspect mon-volume
64

Utilisation des volumes Docker dans les conteneurs

Les volumes Docker peuvent être montés dans des conteneurs à l'aide de l'option -v de la commande docker run.
L'option -v prend en argument le chemin d'accès du volume sur le système hôte et le chemin d'accès du répertoire dans le conteneur où le volume doit être monté.
Exemple : docker run -d --name mon-conteneur -v mon-volume:/var/lib/mysql mysql
65

Utilisation de volumes host dans Docker

Les volumes host dans Docker permettent de monter un répertoire du système hôte dans un conteneur Docker.
Les volumes host sont utiles lorsque vous avez besoin d'accéder à des fichiers ou des répertoires sur le système hôte depuis un conteneur Docker.
Les volumes host peuvent être montés dans des conteneurs à l'aide de l'option -v de la commande docker run.
L'option -v prend en argument le chemin d'accès du répertoire sur le système hôte et le chemin d'accès du répertoire dans le conteneur où le volume host doit être monté.
Exemple : docker run -d --name mon-conteneur -v /chemin/vers/repertoire/hôte:/chemin/vers/repertoire/conteneur mon-image
66

Utilisation de la commande mount dans Docker

La commande mount dans Docker permet de monter un volume ou un bind mount dans un conteneur en cours d'exécution.
La commande mount prend en option l'ID ou le nom du conteneur, le type de montage (volume ou bind), le chemin d'accès du répertoire sur le système hôte et le chemin d'accès du répertoire dans le conteneur où le montage doit être effectué.
Exemple : docker container create --name mon-conteneur --mount type=volume,src=mon-volume,dst=/chemin/vers/repertoire/conteneur mon-image
Pour monter un volume dans un conteneur en cours d'exécution, utilisez la commande docker container update --mount en spécifiant l'ID ou le nom du conteneur, le type de montage, le nom du volume et le chemin d'accès du répertoire dans le conteneur où le montage doit être effectué.
Exemple : docker container update --mount type=volume,src=mon-volume,dst=/chemin/vers/repertoire/conteneur mon-conteneur
67

Suppression des volumes Docker

Les volumes Docker peuvent être supprimés à l'aide de la commande docker volume rm.
La commande docker volume rm prend en option le nom du volume à supprimer.
Les volumes Docker ne peuvent être supprimés que s'ils ne sont pas utilisés par un conteneur en cours d'exécution.
Exemple : docker volume rm mon-volume
68

Gestion des volumes Docker

Les volumes Docker peuvent être gérés à l'aide de la commande docker volume prune.
La commande docker volume prune supprime tous les volumes Docker qui ne sont pas utilisés par un conteneur en cours d'exécution.
La commande docker volume prune prend en option l'option -f pour forcer la suppression des volumes sans confirmation.
Exemple : docker volume prune -f
69

Docker CLI - Commandes de volume

docker volume create : crée un nouveau volume.
docker volume ls : affiche la liste des volumes.
docker volume inspect : affiche des informations détaillées sur un volume.
docker volume prune : supprime tous les volumes inutilisés.
70

Les réseaux
71

Introduction aux réseaux dans Docker

Les réseaux dans Docker permettent de connecter des conteneurs entre eux et de les connecter à des réseaux externes.
Les réseaux dans Docker peuvent être créés, supprimés, inspectés et mis à jour à l'aide de commandes Docker.
Les réseaux dans Docker peuvent être de différents types, tels que bridge, overlay, host et Macvlan.

72

Réseau bridge par défaut

Lorsque vous installez Docker, un réseau bridge par défaut est créé automatiquement.
Le réseau bridge par défaut permet à tous les conteneurs connectés à ce réseau de communiquer entre eux.
Les conteneurs connectés au réseau bridge par défaut peuvent également accéder à des réseaux externes via le pont réseau de l'hôte.
Pour connecter un conteneur au réseau bridge par défaut, utilisez l'option --network=bridge lors de la création du conteneur.
73

Création d'un réseau personnalisé

Pour connecter un conteneur à un réseau, utilisez l'option --network lors de la création du conteneur.
L'option --network prend en argument le nom du réseau auquel le conteneur doit être connecté.
Exemple : docker container create --name mon-conteneur --network mon-reseau mon-image
74

Inspection d'un réseau

Pour inspecter un réseau, utilisez la commande docker network inspect.
La commande docker network inspect prend en option le nom du réseau à inspecter.
La commande docker network inspect affiche des informations détaillées sur le réseau, telles que son nom, son pilote, son adresse IP, ses conteneurs connectés et ses options de configuration.
Exemple : docker network inspect mon-reseau

75

Suppression d'un réseau

Pour supprimer un réseau, utilisez la commande docker network rm.
La commande docker network rm prend en option le nom du réseau à supprimer.
Les réseaux ne peuvent être supprimés que s'ils ne sont pas utilisés par un conteneur en cours d'exécution.
Exemple : docker network rm mon-reseau
76

 Utilisation de réseaux overlay

Uniquement utilisable dans docker swarm
Les réseaux overlay permettent de connecter des conteneurs entre eux sur plusieurs hôtes Docker.
Les réseaux overlay peuvent être créés à l'aide de la commande docker network create avec le pilote overlay.
Pour connecter un conteneur à un réseau overlay, utilisez l'option --network lors de la création du conteneur et spécifiez le nom du réseau overlay.
Les réseaux overlay peuvent être utilisés pour créer des services Docker et des piles Docker avec Docker Compose.

77

docker compose
78

Présentation et utilité de docker compose

docker compose est un outil permettant de définir et de gérer des applications multi-conteneurs dans Docker.
docker compose permet de définir les services, les réseaux et les volumes nécessaires à une application dans un fichier YAML.
docker compose permet de créer, de démarrer, d'arrêter et de supprimer des conteneurs en une seule commande.
docker compose est utile pour le développement, le test et le déploiement d'applications multi-conteneurs.
docker compose est particulièrement utile pour les applications qui nécessitent plusieurs conteneurs pour fonctionner, tels qu'une application web avec une base de données et un serveur web.
docker compose permet de définir les dépendances entre les conteneurs et de gérer leur cycle de vie.
docker compose permet également de définir des variables d'environnement, des volumes et des réseaux pour les conteneurs.
docker Compose permet de déployer des applications sur un hôte Docker ou sur un cluster Docker avec Docker Swarm.
Intégré maintenant dans la CLI docker

79

Création d'un fichier docker-compose.yml

Pour utiliser Docker Compose, vous devez créer un fichier docker-compose.yml dans le répertoire de votre application.
Le fichier docker-compose.yml décrit les services, les réseaux et les volumes nécessaires à votre application.
Le fichier docker-compose.yml utilise le format YAML pour définir les services, les réseaux et les volumes.

80

Définition des services

es services sont les conteneurs qui composent votre application.
Pour définir un service, vous devez spécifier le nom du service, l'image Docker à utiliser, les ports à exposer et les volumes à monter.
Vous pouvez également spécifier des variables d'environnement, des dépendances et des commandes à exécuter dans le conteneur.
Exemple :
version: '3'
services:
  web:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html
  db:
    image: postgres:latest
    environment:
      - POSTGRES_USER=myuser
      - POSTGRES_PASSWORD=mypassword
      - POSTGRES_DB=mydb
81

Définition des réseaux

Les réseaux permettent de connecter les services entre eux et de les isoler du réseau hôte.
Pour définir un réseau, vous devez spécifier le nom du réseau, le pilote de réseau et les options de configuration du réseau.
Vous pouvez également spécifier des alias pour les services et des sous-réseaux pour les réseaux.
Exemple :
version: '3'
services:
  web:
    image: nginx:latest
    networks:
      - mynet
  db:
    image: postgres:latest
    networks:
      - mynet
networks:
  mynet:
    driver: bridge
    ipam:
      config:
        - subnet: 172.18.0.0/16
82

Définition des volumes

Les volumes permettent de stocker des données persistantes en dehors des conteneurs.
Pour définir un volume, vous devez spécifier le nom du volume, le chemin d'accès du répertoire sur l'hôte et le chemin d'accès du répertoire dans le conteneur.
Vous pouvez également spécifier des options de montage pour les volumes.
Exemple :

version: '3'
services:
  web:
    image: nginx:latest
    volumes:
      - myvol:/usr/share/nginx/html
volumes:
  myvol:
    driver: local
    driver_opts:
      type: none
      device: /path/to/my/html
      o: bind
83

Définition des variables d'environnement

Les variables d'environnement permettent de configurer les services en fonction de l'environnement de déploiement.
Pour définir des variables d'environnement, vous devez spécifier le nom de la variable et sa valeur.
Vous pouvez également utiliser des fichiers de variables d'environnement externes pour stocker les variables d'environnement.
Exemple :
version: '3'
services:
  web:
    image: nginx:latest
    environment:
      - API_HOST=api.example.com
      - API_PORT=8080

84

Gestion de plusieurs conteneurs avec Docker Compose

Docker Compose permet de gérer plusieurs conteneurs en une seule commande.
Pour gérer plusieurs conteneurs avec Docker Compose, vous devez définir les services, les réseaux et les volumes nécessaires à votre application dans un fichier docker-compose.yml.
Vous pouvez ensuite utiliser les commandes docker-compose up, docker-compose down, docker-compose ps et docker-compose logs pour gérer les conteneurs.

85

Démarrage des conteneurs avec docker-compose up

La commande docker-compose up permet de démarrer tous les conteneurs définis dans le fichier docker-compose.yml.
La commande docker-compose up crée également les réseaux et les volumes nécessaires à l'application.
Vous pouvez utiliser l'option -d pour démarrer les conteneurs en arrière-plan.
Exemple : docker-compose up -d
86

Arrêt des conteneurs avec docker-compose down

La commande docker-compose down permet d'arrêter et de supprimer tous les conteneurs définis dans le fichier docker-compose.yml.
La commande docker-compose down supprime également les réseaux et les volumes créés par Docker Compose, sauf si vous utilisez l'option -v pour conserver les volumes.
Exemple : docker-compose down
87

Affichage des conteneurs en cours d'exécution avec docker-compose ps

La commande docker-compose ps permet d'afficher les conteneurs en cours d'exécution définis dans le fichier docker-compose.yml.
La commande docker-compose ps affiche également l'état, le port et le nom de chaque conteneur.
Exemple : docker-compose ps
88

Affichage des journaux des conteneurs avec docker-compose logs
La commande docker-compose logs permet d'afficher les journaux des conteneurs définis dans le fichier docker-compose.yml.
Vous pouvez utiliser l'option -f pour suivre les journaux en temps réel.
Vous pouvez également spécifier le nom du conteneur pour afficher les journaux d'un conteneur spécifique.
Exemple : docker-compose logs -f web

89

Mise à jour des conteneurs avec docker-compose up
La commande docker-compose up permet également de mettre à jour les conteneurs en cas de modification du fichier docker-compose.yml.
Pour mettre à jour les conteneurs, vous devez arrêter les conteneurs en cours d'exécution avec docker-compose down, puis redémarrer les conteneurs avec docker-compose up.
Docker Compose télécharge automatiquement les nouvelles images Docker si nécessaire.
Exemple : docker-compose down && docker-compose up -d
90

Sécurité avec Docker
91

Docker sécurisé par défaut
92

Bonnes pratiques de sécurité avec Docker
Docker est une technologie puissante, mais elle peut également présenter des risques de sécurité si elle n'est pas utilisée correctement.

Les bonnes pratiques de sécurité avec Docker comprennent la gestion des utilisateurs, des images, des réseaux et des conteneurs.

93

Gestion des utilisateurs
Limitez l'accès à Docker aux utilisateurs de confiance.
N'exécutez pas le démon Docker en tant que root. rootless
Utilisez des groupes d'utilisateurs pour contrôler l'accès à Docker.
Exemple : créez un groupe docker et ajoutez les utilisateurs autorisés à ce groupe.

94

Gestion des images
Utilisez des images Docker officielles et de confiance.
Vérifiez les signatures des images Docker avant de les utiliser.
Mettez à jour régulièrement les images Docker pour corriger les vulnérabilités de sécurité.
Exemple : utilisez l'option --pull always pour télécharger la dernière version de l'image lorsque vous démarrez un conteneur.

95

Gestion des réseaux
Utilisez des réseaux Docker isolés pour les conteneurs.
Limitez l'exposition des ports réseau aux conteneurs qui en ont besoin.
Utilisez des pare-feu pour protéger les réseaux Docker.
Exemple : créez un réseau Docker isolé pour votre application et exposez uniquement les ports nécessaires.
96

Gestion des conteneurs


Limitez les privilèges des conteneurs.
Utilisez des utilisateurs non-root dans les conteneurs.
Utilisez des volumes Docker pour stocker les données sensibles.
Exemple : utilisez l'option --user pour spécifier un utilisateur non-root dans le conteneur et l'option -v pour monter un volume Docker pour stocker les données sensibles.

97

Analyse de sécurité des images Docker


Utilisez des outils d'analyse de sécurité pour détecter les vulnérabilités dans les images Docker.
Intégrez l'analyse de sécurité dans votre pipeline de développement.
Corrigez les vulnérabilités détectées avant de déployer les images Docker.
98

Surveillance de la sécurité des conteneurs


Surveillez les conteneurs en cours d'exécution pour détecter les activités suspectes.
Utilisez des outils de surveillance de la sécurité pour détecter les attaques et les violations de sécurité.
Répondez rapidement aux incidents de sécurité en arrêtant les conteneurs affectés et en corrigeant les vulnérabilités.
99

Exemples d’outils open source


Docker Bench for Security : C'est un script de vérification de la sécurité qui vérifie si Docker est déployé conformément aux bonnes pratiques de sécurité recommandées par le Center for Internet Security (CIS).
Falco : C'est un outil de détection d'intrusion pour les conteneurs qui utilise des règles pour détecter les comportements suspects dans les conteneurs en cours d'exécution.
Sysdig : C'est une plateforme de visibilité et de sécurité pour les conteneurs qui fournit une surveillance en temps réel, une analyse des causes profondes et une réponse aux incidents de sécurité.
Clair : C'est un outil d'analyse de vulnérabilité pour les images Docker qui analyse les images pour détecter les vulnérabilités connues et fournit des rapports détaillés.
Anchore : C'est une plateforme de sécurité pour les conteneurs qui fournit une analyse statique et dynamique des images Docker, une gestion des politiques de sécurité et une intégration avec les outils de développement et de déploiement.
100

Aller plus loin…
101

Docker c’est aussi…


Documentation officielle de Docker : https://docs.docker.com/
Docker Hub : https://hub.docker.com/
Docker Captains : https://www.docker.com/community/captains
DockerCon : https://www.docker.com/dockercon/
Dive into Docker : https://diveintodocker.com/
Docker Mastery : https://www.udemy.com/course/docker-mastery/

102
