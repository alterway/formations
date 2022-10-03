# Les workspaces

### Qu’est-ce qu'un workspace

- Simplement des fichiers d'état (`terraform.tfstate`) gérés de manière indépendante
- Un workspace contient tout ce dont terraform à besoin pour gérer un configuration d'infrastructure
- les workspaces fonctionnent comme des répertoires de travail
- Les workspaces pemettent de gérer différents environnements sans modifier les configurations

- Chaque environnement à son prope état
- Les ressources peuvent être nommées dynamiquement avec le nom du workspace
- Les espaces de travail garantissent que les environnements sont isolés et mis en miroir.
- Les espaces de travail sont le successeur des anciens `Terraform Environments`


### Cas d'usage pour les workspaces

- Environnements
    - Production
    - Staging 
    - Dev 
    - ...
- Zones
    - northeurope
    - westeurope
    - us-east-1
    - eu-west-2
- Différentes subscriptions/account
  - arn
  - sub
  - ...
- Clients
  - Usine à sites
  - ...

### Comment manipuler les workspace

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
# Créer un workspace
terraform workspace new Production
terraform workspace new Staging

# Sélectionner un workspace
terraform workspace select Production

# Lister les workspaces
terraform workspace list

# Créer un plan
terraform plan -out prod.tfplan

# Appliquer le plan
terraform apply  prod.tfplan

# Sur quel workspace suis-js
terraform workspace show

# Supprimer un workspace
terraform workspace Staging

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Les workspaces (vue interne : local state )

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
resource "azurerm_resource_group" "rg_1" {
  name     = "a-herlec-rg-${terraform.workspace}-01"
  location = "northeurope"
  tags = {
    createdBy = "herlec"
    BU        = "DT"
  }
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

❯ tree -a terraform.tfstate.d
terraform.tfstate.d
├── Production
│   └── terraform.tfstate
└── Staging
    ├── terraform.tfstate
    └── terraform.tfstate.backup

2 directories, 3 files

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Les workspaces avec les backend distants  (1)

![](images/terraform/workspace-remote-backend.png){height="447px"}



### Les workspaces avec les backend distants  (1)
   
![](images/terraform/workspace-remote-backend-state.png)

