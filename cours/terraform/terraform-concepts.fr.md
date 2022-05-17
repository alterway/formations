# Formation Terraform - Architecture et Concepts

### Terraform Core

- Binaire écrit en Go, open source

- Ligne de commande qui communique avec des plugins Terraform au travers du protocole RPC (**R**emote **P**rocedure **C**all)

- Interface commune qui supporte différents fournisseurs cloud et fournisseurs de services

- Gère les fichiers d’état des ressources

- Construit le graphe des ressources

### Terraform Provider

- Binaire Go invoqué par Terraform Core

- Communication avec les API des fournisseurs de services  (ex: AWS, GCP, Azure, Docker, K8s, etc.)

- Possibilité d’en utiliser plusieurs

- Initialise et installe les dépendances nécessaires

- Gère l’authentification

- Exécute les commandes et les scripts

- Listes des différents providers disponibles https://registry.terraform.io/browse/providers  


### Terraform Core & Terraform plugins



![](images/terraform/terraform_protocol_registry.png)


