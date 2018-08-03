# Supports de formation Osones

![Build Status](https://codebuild.eu-west-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiUkRNdlZtY2JhbVlPb3ZJaDExeXlwT2hjRVhocmRVUGRQRnZtZCsyM0g4RGp2WHZKMzhUWUcxd0xSWVJncUNzRllCTFJBZmwrMTE5Q01iN0d5MEQ2aVZZPSIsIml2UGFyYW1ldGVyU3BlYyI6ImpzWHAzUXJDVUd5MlAxQzQiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)

Supports de formation (sous forme de slides) écrits en Français et traduits en Anglais et réalisés par [Osones](https://osones.com/) pour ses offres de [formation](https://osones.com/formations.html).

Sont notamment abordés les sujets suivants : le cloud, sa philosophie, le projet OpenStack, l'utilisation d'OpenStack, le déploiement d'OpenStack, le principe des conteneurs, le projet Docker, l'utilisation de Docker, l'orchestration de conteneurs Docker.

Auteurs :

* Adrien Cunin <adrien.cunin@osones.com>
* Pierre Freund <pierre.freund@osones.com>
* Romain Guichard <romain.guichard@osones.com>
* Kevin Lefevre <kevin.lefevre@osones.com>
* Jean-François Taltavull <jft@osones.com>

HTML et PDF construits automatiquement :

* [Support PDF OpenStack User](https://osones.com/formations/pdf/openstack-user.fr.pdf)
* [Support PDF OpenStack Admin](https://osones.com/formations/pdf/openstack.fr.pdf)
* [Support HTML OpenStack User](https://osones.com/formations/openstack-user.fr.html)
* [Support HTML OpenStack Admin](https://osones.com/formations/openstack.fr.html)
* [Support HTML Docker](https://osones.com/formations/docker.fr.html)

## Prérequis

### Option 1 : Utiliser le Makefile

* make : <https://www.gnu.org/software/make/>
* jq : <https://github.com/stedolan/jq>
* pandoc : <https://pandoc.org>
* TeX Live : <https://www.tug.org/texlive/>

### Option 2 : Utiliser le script build.sh

* Docker : <https://docs.docker.com/install>

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

- [revealjs-builder](https://github.com/Osones/docker-images/tree/master/revealjs-builder)
- [wkhtmltopdf](https://github.com/Osones/docker-images/tree/master/wkhtmltopdf)

Un daemon Docker est donc le seul pré-requis pour le build via `build.sh`

```
  USAGE : $0 options

    -o output           Output format (html, pdf or all). If none, all outputs
                        are built

    -t theme            Theme to use, default to osones

    -u revealjsURL      RevealJS URL that need to be use. If you build formation
                        supports on local environment you should git clone http://github.com/hakimel/reveal.js
                        and set this variable to your local copy.
                        This option is also necessary even if you only want PDF
                        output (default : https://osones.com/formations/revealjs)

    -c course           Courses to build, if not specified all courses are built
```

If you want to build the courses locally, you'll need to :

- pull the Docker image osones/revealjs-builder
- pull the Docker image osones/wkhtmltopdf
- clone http://github.com/hakimel/reveal.js (see `-u` parameter)

Pour visualiser :

- Lire les fichiers HTML dans `cours/output-html/` avec votre navigateur
- Les PDF se trouvent dans `output-pdf/`

OU

```
docker run -d \
            -p 80:8001 \
            -v $PWD/images:/revealjs/images \
            -v $PWD/cours/output-html/$(cours).html:/revealjs/index.html \
            -v $PWD/cours/output-html/revealjs/css/theme:/revealjs/css/theme \
            vsense/revealjs
```

- Les slides sont ensuite accessibles sur http://localhost

### Makefile

Le build se fait entièrement en local.

* Voir le header du Makefile pour les dépendances nécessaires.
* Voir `make help` pour l'utilisation.

Quelques exemples :

    make openstack.pdf
    make docker-handout.pdf
    make docker-print.pdf
    make openstack.html

## Copyright et licence

Tous les contenus originaux (Makefile, scripts, fichiers dans `cours/`) sont :

* Copyright © 2014-2018 Osones
* Distribués sous licence Creative Commons BY-SA 4.0 (<https://creativecommons.org/licenses/by-sa/4.0/>)

![Creative Commons BY-SA](http://mirrors.creativecommons.org/presskit/buttons/88x31/png/by-sa.png)

Les autres fichiers du répertoire `images/` sont soumis à leur copyright et licence respectifs.

