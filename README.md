# Supports de formation alter way Cloud Consulting

![Build Status](https://codebuild.eu-west-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiUkRNdlZtY2JhbVlPb3ZJaDExeXlwT2hjRVhocmRVUGRQRnZtZCsyM0g4RGp2WHZKMzhUWUcxd0xSWVJncUNzRllCTFJBZmwrMTE5Q01iN0d5MEQ2aVZZPSIsIml2UGFyYW1ldGVyU3BlYyI6ImpzWHAzUXJDVUd5MlAxQzQiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)

Supports de formation (sous forme de slides) écrits en Français et traduits en Anglais et réalisés par [alter way Cloud Consulting](https://alterway.fr/) (ex Osones) pour ses offres de [formation](https://formation.alterway.fr/cloud/).

Sont notamment abordés les sujets suivants : le cloud, sa philosophie, le projet OpenStack, l'utilisation d'OpenStack, le déploiement d'OpenStack, le principe des conteneurs, le projet Docker, l'utilisation de Docker, l'orchestration de conteneurs Docker.

Sources : <https://github.com/alterway/formations/>

Auteurs :

* Adrien Cunin <adrien.cunin@alterway.fr>
* Pierre Freund <pierre.freund@alterway.fr>
* Romain Guichard <romain.guichard@alterway.fr>
* Kevin Lefevre <kevin.lefevre@alterway.fr>
* Jean-François Taltavull <jean-francois.taltavull@alterway.fr>

HTML et PDF construits automatiquement : <https://osones.com/formations/>

* OpenStack User [PDF](https://osones.com/formations/pdf/openstack-user.fr.pdf)/[HTML](https://osones.com/formations/openstack-user.fr.html)
* OpenStack Ops [PDF](https://osones.com/formations/pdf/openstack-ops.fr.pdf)/[HTML](https://osones.com/formations/openstack-ops.fr.html)
* Kubernetes User [PDF](https://osones.com/formations/pdf/kubernetes-user.fr.pdf)/[HTML](https://osones.com/formations/kubernetes-user.fr.html)
* Kubernetes Ops [PDF](https://osones.com/formations/pdf/kubernetes-ops.fr.pdf)/[HTML](https://osones.com/formations/kubernetes-ops.fr.html)
* Cloud [PDF](https://osones.com/formations/pdf/cloud.fr.pdf)/[HTML](https://osones.com/formations/cloud.fr.html)
* Docker [PDF](https://osones.com/formations/pdf/docker.fr.pdf)/[HTML](https://osones.com/formations/docker.fr.html)

## Prérequis


### Option 1 : Utiliser le script build.sh

* Docker : <https://docs.docker.com/install>
* jq : <https://github.com/stedolan/jq>

### Option 2 : Utiliser le Makefile

* make : <https://www.gnu.org/software/make/>
* jq : <https://github.com/stedolan/jq>
* pandoc : <https://pandoc.org>
* TeX Live : <https://www.tug.org/texlive/>

## Fonctionnement

Les supports de formation (slides) sont écrits en Markdown. Chaque fichier dans `cours/` est un module indépendant.

`cours.json` définit les cours à partir des modules.

Il est possible de générer ces slides sous différents formats :

1. HTML / reveal.js
2. PDF à partir du HTML / reveal.js
3. PDF à partir de LaTeX / Beamer

Deux méthodes de build sont disponibles :

* build.sh : supporte 1. et 2.
* Makefile : supporte 1. et 3.

### Build.sh

Le build utilise des conteneurs Docker.
L'utilisation de conteneurs Docker ne vise qu'à fournir un environnement stable (version des paquets fixes)
et de ne pas "encrasser" le système hôte avec des paquets dont l'utilisation est faible.

Les Dockerfiles des images Docker sont disponibles ici :

- [revealjs-builder](https://hub.docker.com/r/alterway/revealjs-builder)
- [wkhtmltopdf](https://hub.docker.com/r/alterway/wkhtmltopdf)

Un daemon Docker est donc le seul pré-requis pour le build via `build.sh`

```
 USAGE : ./build.sh options

    -o output           Output format (html, pdf or all). Default: all

    -t theme            Theme to use. Default: awcc

    -u revealjsURL      RevealJS URL that need to be use. If you build formation
                        supports on local environment you should git
                        clone https://github.com/hakimel/reveal.js and set
                        this variable to your local copy.
                        This option is also necessary even if you only want PDF
                        output. Default: https://osones.com/formations/revealjs

    -c course           Course to build, "all" for build them all !

    -l language         Language in which you want the course to be built. Default: fr
```

#### Theme

Les thèmes sont stockés dans `styles/`. Un thème est constitué de :

- un fichier CSS
- un dossier (nom du thème) contenant les assets (images, font, etc)

#### Reveal.js

Par défaut, nous utilisons une version forkée de reveal.js. Pour utiliser votre
propre version, vous devez spécifier son chemin avec le paramètre `-u`. Les
fichiers de votre thème seront copiés dans ce chemin. Si le chemin est distant
(uptream version par exemple), vous ne pourrez utiliser votre propre thème.

#### Language

Nous supportons le multi langage. Le script `build.sh` est conçu pour
rebasculer sur le contenu français si le cours n'existe pas dans la langue
demandée.

#### Exemples


```console
./build.sh -c docker -l fr -o html
./build.sh -o pdf
./build.sh -c openstack-user -u ~/reveal.js
./build.sh -c kubernetes-ops -l en -t customer
```

- Les fichiers HTML se trouvent dans `output-html/`
- Les PDF se trouvent dans `output-pdf/`

En ayant puller au préalable les deux images Docker et en ayant une copie
locale de reveal.js (spécifié avec `-u`), les builds se font uniquement en
local.

### Makefile

Le build se fait entièrement en local.

* Voir le header du Makefile pour les dépendances nécessaires.
* Voir `make help` pour l'utilisation.

Quelques exemples :

```console
make openstack.pdf
make docker-handout.pdf
make docker-print.pdf
make openstack.html
```

## Copyright et licence

Tous les contenus originaux (Makefile, scripts, fichiers dans `cours/`) sont :

* Copyright © 2014-2019 alter way Cloud Consulting
* Distribués sous licence Creative Commons BY-SA 4.0 (<https://creativecommons.org/licenses/by-sa/4.0/>)

![Creative Commons BY-SA](https://mirrors.creativecommons.org/presskit/buttons/88x31/png/by-sa.png)

Les autres fichiers du répertoire `images/` sont soumis à leur copyright et licence respectifs.

