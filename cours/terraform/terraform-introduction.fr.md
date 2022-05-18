# Introduction

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

### Terraform

![](images/terraform/terraform_logo.svg.png){height="123px"}



- Outil d’IaC **open** **source** publié par [HashiCorp*](https://www.hashicorp.com/products/terraform)

- Utilisé pour gérer les infrastructures grâce à la **configuration** **déclarative**

- Cloud agnostic (Amazon, Google, Azure, ...) (Via des providers)

- Utilise le langage [HCL](https://www.terraform.io/language)

- Permet de bénéficier des avantages de l’IaC

- Gère tout type de ressources : stockage, réseau, entrées DNS, Vms, PaaS...


### Quelques faits 

- En 2022 :  ~2098 providers (35 Officiels, 206 Vérifiés, 1857 Communautaires )
- Terraform utilise un DSL spécifique : `HCL` (HashiCorp Configuration Language)
- Terraform est outils orienté plugin
- Terraform a un support natif pour les `modules`et les `remote states`
- Terraform fournit une abstraction dehaut niveau de l'infrastructure au travers des `resources`
- Terraform peut géré du **IAAS**, **PAAS**, **SAAS**
- Terraform peut faire du `dry-run` (`plan` vs `apply`)
- Terraform peut gérer tout type de resources qui a une api
  

### Impératif vs Déclaratif

![](images/terraform/declaratif-imperatif.png){height="620px"}

### Installer Terraform CLI

- Ouvrir le lien [https://learn.hashicorp.com/tutorials/terraform/install-cli](https://learn.hashicorp.com/tutorials/terraform/install-cli)

- Suivre les instructions pour installer Terraform CLI selon le système d’exploitation

- Vérifier la version installée avec la commande : `terraform version`

```console 
terraform version
Terraform v1.1.9
on darwin_amd64
```

