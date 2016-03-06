# Build du cours Docker

## Pré-requis

* Docker

## Instructions

Se placer à la racine du repository git

Build du contenu en reveal.js :
 `docker run --rm -v $PWD:/formations osones/revealjs-builder /bin/bash /build-docker.sh`

Pour interpréter le reveal.js généré :
`docker run -d --name revealjs -p 80:8001 -v $PWD/latex/docker/images:/revealjs/images -v $PWD/latex/docker/index.html:/revealjs/index.html vsense/revealjs`

Résultat : http://localhost


Build du cours en PDF (nécessite d'avoir buildé le contenu en reveal.js) :
`docker run --rm -v $PWD/:/formations  astefanutti/decktape /formations/docker-s3/index.html /formations/docker.pdf`

Résultat : $PWD/docker.pdf
