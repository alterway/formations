## Concevoir l'infra d'une application "cloud ready"

### Une infra, ça évolue !

-   Sizing des clusters
-   Ugrade des O.S. « guest » et du middleware
-   Règles SSI : segmentation réseau, filtrage de flux, proxys, bastions, annuaires
-   Ajout de nouveaux services

### Mécaniser, automatiser, industrialiser

-   Notions expliquées
-   Reproductibilité
-   C'est Automagique !

### Automatisation

-   Mécaniser la gestion de l’infrastructure : indispensable
-   Automatiser la gestion de l’infrastructure : un plus !
-   Création des ressources
-   Configuration des ressources

### Infrastructure as Code

-   L'infra s'appréhende comme du code
-   Travailler comme un développeur
-   Décrire son infrastructure sous forme de code (Heat, Terraform)
-   Suivre les changements dans un VCS (git)
-   Mettre en oeuvre un système d'intégration et déploiement continus (CI/CD)

### Approche de Heat

-   Un service / une API OpenStack
-   Notions de stack et description YAML
-   Précautions d'usage (stack update)
-   Cas d'usage type

### Exemple Heat

```
---
heat_template_version: 2018-08-31
description: A single nova instance
parameters:
  flavorName:
    type: string
resources:
  instance:
    type: OS::Nova::Server
    properties:
      name: MonInstance
      image: debianStretchOfTheDay
      flavor: {get_param: flavorName}
      key_name: MaCleSSH
outputs:
  instanceId:
    value: {get_resource: instance}
```

### Approche de Terraform

-   L'aspect "cloud agnostique"
-   Le DSL de Terraform
-   L'exigence Infra as Code
-   Cas d'usage type

### Exemple Terraform

```
#  A single nova instance

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "MyName"
  tenant_name = "MyTenant"
  password    = "MyPwd"
  auth_url    = "http://myauthurl:5000/v2.0"
  region      = "RegionOne"
}

resource "openstack_compute_instance_v2" "MonInstance" {
  name            = "MonInstance"
  count           = "1"
  image_name      = ""
  flavor_name     = "${var.flavor}"
  key_pair        = "MaCleSSh"
}
```

### Agilité et CI/CD appliquées à l'infra
 
-   Style de code
-   Validation de la syntaxe
-   Tests unitaires
-   Tests d'intégration
-   Tests de déploiement complet

### Tolérance aux pannes

-   Tirer parti des capacités de l'application
-   Ne pas tenter de rendre l'infrastructure compute HA

### Autoscaling group

-   Groupe d’instances similaires
-   Nombre variable d’instances
-   Scaling automatique en fonction de métriques
-   Permet le passage à l'échelle *horizontal*

### Monitoring

-   Prendre en compte le cycle de vie des instances : DOWN != ALERT
-   Monitorer le service plus que le serveur

### Backup

-   Être capable de recréer ses instances (et le reste de son infrastructure)
-   Données (applicatives, logs) : block, objet

### Comment gérer ses images ?

-   Utilisation d’images génériques et personnalisation à l’instanciation (cloud-init)
-   Création d’images offline :
    -   *from scratch* : diskimage-builder (TripleO)
    -   *from scratch* avec des outils spécifiques aux distributions (`openstack-debian-images` pour Debian)
    -   modifiées avec libguestfs, virt-builder, virt-sysprep
-   Création d’images via une instance :
    -   automatisation possible avec Packer, Terraform, le CLI ou les API du IaaS
    -   Golden images

