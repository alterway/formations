# OpenShift : Introduction

### OpenShift

- Solution de PaaS développée par Red Hat

- Deux version :
    - Open Source : [OpenShift Origin](https://www.openshift.org/)
    - Entreprise : [OpenShift Container Platform](https://www.openshift.com/)

- Se base sur Kubernetes en tant qu'orchestrateur de conteneurs

### OpenShift VS Kubernetes : Différences et ajouts

- Pas d'Ingress : Router

- Build et Images Stream : Création d'images et pipeline de CI/CD

- Templates : Permet de definir et templatiser facilement un ensemble d'Objet OpenShift

- OpenShift SDN ou Nuage Network pour le réseau

### OpenShift : Router

- Quasiment identique à Ingress mais implémentés avant Kubernetes

- Fournissent les même fonctionnalités

- Deux implementations :
    - HAProxy
    - F5 Big IP

### OpenShift : Build

- Permet de construire et reproduire des images d'application

- Docker builds : via Dockerfile

- Source-to-Image (S2I) builds : système de build propre à OpenShift qui produit une image Docker d'une application depuis les source

- Pipeline builds : via Jenkins

### OpenShift : Image Stream

- Similaires à un dépôt DockerHub

- Rassemble des images similaires identifiées par des tags

- Permet de garder un historique des différentes versions

### OpenShift : Conclusion

