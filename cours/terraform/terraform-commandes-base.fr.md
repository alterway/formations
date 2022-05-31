

# Les commandes de base

### terraform `init`

- À exécuter avant toute autre commande ou après l’ajout de nouvelles ressources

- Prépare le répertoire pour l’utilisation de Terraform

- Elle permet :
    - D’initialiser les backends 
    - D’installer les modules
    - D’installer les plugins

🟢 **Bonne pratique** : l’exécuter souvent

![](images/terraform/terraform-init.png){height="300px"}


### terraform `plan`

- Génère un plan d’exécution

- Met à jour le fichier d’état avec l’état courant des ressources

- Compare la configuration à l’état des ressources dans le fichier d’état

- Affiche les changements qui vont intervenir

![](images/terraform/terraform-plan.png){height="300px"}


### terraform `apply` (1)

- Exécute les changements proposés par le plan 

![](images/terraform/terraform-apply-1.png){height="300px"}


### terraform `apply` (2)

![](images/terraform/terraform-apply-2.png){height="300px"}


### Fichiers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
terraform init
# Voir les fichiers / répertoires créés dans le répertoire courant
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

```bash

.terraform
└── providers
    └── registry.terraform.io
        └── hashicorp
            └── aws
                └── 4.14.0
                    └── darwin_amd64
                        └── terraform-provider-aws_v4.14.0_x5

```

### terraform `destroy` (1)

- Supprime les ressources définies dans le plan (gérées par terraform)

- Utile surtout pour les environnements éphémères 


![](images/terraform/terraform-destroy-1.png){height="300px"}



### terraform `destroy` (2)

![](images/terraform/terraform-destroy-2.png){height="300px"}


