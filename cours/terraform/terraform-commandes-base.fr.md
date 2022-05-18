

# Les commandes de base

### terraform `init`

- À exécuter avant toute autre commande ou après l’ajout de nouvelles ressources

- Prépare le répertoire pour l’utilisation de Terraform

- Elle permet :
    - D’initialiser les backends 
    - D’installer les modules
    - D’installer les plugins

- **Bonne pratique** : l’exécuter souvent


### terraform `plan`

- Génère un plan d’exécution

- Met à jour le fichier d’état avec l’état courant des ressources

- Compare la configuration à l’état des ressources dans le fichier d’état

- Affiche les changements qui vont intervenir


### terraform `apply`

- Exécute les changements proposés par le plan 



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

### terraform `destroy`

- Supprime les ressources définies dans le plan


