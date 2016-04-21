# Build du cours Docker

## Pré-requis

* Docker

## Instructions

Se placer à la racine du repository git

Build du contenu en reveal.js :
 `docker run -it -v $PWD:/formations osones/revealjs-builder /build.sh`

Pour interpréter le reveal.js généré :
`docker run -d -p 80:8001 -v $PWD/images:/revealjs/images -v $PWD/cours/docker/output-html/index.html:/revealjs/index.html -v $PWD/cours/styles/osones.css vsense/revealjs`

Résultat : http://localhost


Build du cours en PDF (nécessite d'avoir buildé le contenu en reveal.js) :
`docker run --rm -v $PWD:/formations astefanutti/decktape /formations/latex/docker/revealjs/index.html /formations/docker.pdf`

Résultat : $PWD/docker.pdf
