# Formation Terraform - Introduction

### Qu’est-ce que l’Infrastructure as code (IaC) ?

- Utilisation de code combiné à des API pour créer, gérer et supprimer des ressources

- Appliquer les bonnes pratiques du développement dans la gestion de l’infrastructure (tests, revues de code…)

- **Objectif** : automatiser la gestion de l’infrastructure

### Avantages principaux de l’IaC

- Versionning 
- Réutilisabilité
- Reproductibilité
- Automatisation
- Gain de temps
- Idempotence
- Prédictibilité
- Intégration aux outils de CI/CD

### Cycle de vie de  l’Infrastructure

- T0 :
  - Configuration & Initialisation
- T1 :
  - Application de configuration Post Initialisation

### Terraform Késaco ?

- Outil d’IaC **open** **source** publié par **HashiCorp**

- Utilisé pour gérer les infrastructures grâce à la **configuration** **déclarative**

- Cloud agnostic (Amazon, Google, Azure, ...) (Via des providers)

- Utilise le langage **HCL**

- Permet de bénéficier des avantages de l’IaC

- Gère tout type de ressources : stockage, réseau, entrées DNS, Vms, PaaS...


### Installer Terraform CLI

- Ouvrir le lien https://learn.hashicorp.com/tutorials/terraform/install-cli 

- Suivre les instructions pour installer Terraform CLI selon le système d’exploitation

- Vérifier la version installée avec la commande : `terraform version`

```console 
terraform version
Terraform v1.1.9
on darwin_amd64
```

