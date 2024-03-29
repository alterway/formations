# Architecture et Concepts

### Terraform Core

- Binaire écrit en **Go**, open source

- Ligne de commande qui communique avec des **plugins** Terraform au travers du protocole **RPC** (**R**emote **P**rocedure **C**all)

- Interface commune qui supporte **différents** **fournisseurs** **cloud** et **fournisseurs** **de services**

- Gère les **fichiers** **d’état** des ressources (states)

- Construit le **graphe** des ressources (Dépendances entre les ressources)

### Terraform Provider

- Binaire **Go** invoqué par Terraform Core

- Communication avec les **API** des fournisseurs de services  (ex: AWS, GCP, Azure, Docker, K8s, etc.)

- Possibilité d’en utiliser **plusieurs**

- **Initialise** et **installe** les dépendances nécessaires

- Gère **l’authentification**

- **Exécute** les commandes et les scripts

- Liste des différents providers disponibles : [ https://registry.terraform.io/browse/providers](https://registry.terraform.io/browse/providers) 


### Terraform Core & Terraform plugins



![](images/terraform/terraform_protocol_registry.png)


