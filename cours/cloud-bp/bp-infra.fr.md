# Concevoir une infra pour le cloud

### L'infra au service de son application

-  Souplesse
-  Résilience
-  Performance
-  Opérabilité

### Une infra, ça évolue !

-   Dimensionnement des clusters
-   Maintenance des O.S. « guest » et du middleware
-   Règles SSI : segmentation réseau, filtrage de flux, proxys, bastions, annuaires
-   Ajout de nouveaux services

### Mécaniser, automatiser, industrialiser

-   *Le niveau d'anxiété des comités face à la décision de déployer est inversement proportionnelle à la fréquence des MEP => cercle vicieux*
-   (re)Construire, faire évoluer et maintenir les infras hébergées dans le cloud
-   Reconstruction totale ou partielle à la demande
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
-   Suivre les changements dans un VCS (git), qui devient la référence
-   Mettre en oeuvre un système d'intégration et de déploiement continus (CI/CD)

### Approche de Heat

-   Un service <-> une API OpenStack
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
-   L'exigence Infra as Code (terraform.tfstate)
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
-   Vérification de la syntaxe
-   Tests unitaires
-   Tests d'intégration
-   Tests fonctionnels de bout en bout

### Tolérance aux pannes

-   Notion de résilience
-   Load balancers
-   Floating IPs
-   Groupes de serveurs stateless
-   Healthchecks

### Mise à l'échelle / élasticité horizontale

-   Groupe d’instances similaires, autoscaling group
-   Nombre d’instances variable
-   Scaling automatique en fonction de métriques

### Supervision

-   Prendre en compte le cycle de vie des instances : DOWN != ALERT
-   Monitorer les services plutôt que les serveurs
-   Oublier les adresses IP ! Exposer un web service
-   Prévoir un healthcheck fonctionnel (use case "métier")

### Backup, PCA

-   Infrastructure : être capable de reconstruire n'importe quel environnement à tout moment
-   Données (de l'application, logs) : utiliser les modes de stockage bloc (volumes) et objet (dossiers)

### Gérer ses images

-   Utilisation d’images génériques et personnalisation à l’instanciation (cloud-init)
-   Création d’images offline :
    -   *from scratch* : diskimage-builder (TripleO)
    -   *from scratch* avec des outils spécifiques aux distributions (`openstack-debian-images` pour Debian)
    -   modifiées avec libguestfs, virt-builder, virt-sysprep
-   Création d’images via une instance :
    -   automatisation possible avec Packer, Terraform, le CLI ou les API du IaaS
    -   Golden images

