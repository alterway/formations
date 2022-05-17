

# Configuration Terraform

### Qu'est-ce que c'est ?

Une **configuration** Terraform est un fichier texte qui contient les définitions des **ressources** d'infrastructure. Il est possible d'écrire des configurations Terraform au format HCL (avec l'extension .tf) ou au format JSON (avec l'extension .tf.json).

### resources

- Les ressources sont les éléments de base d'une configuration Terraform. 

- Lorsque vous définissez une configuration, vous définissez une ou plusieurs (généralement plusieurs) ressources. 
- Les ressources sont spécifiques au `provider`, de sorte qu'une ressource pour le provider AWS est différente d'une ressource pour OpenStack. 

- Élément le plus important dans Terraform

- Chaque ressource décrit un ou plusieurs éléments d’infrastructure

- Plusieurs méta-arguments
  - count
  - depends_on
  - for_each
  - provider
  - lifecycle
  - provisioner et connection


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

resource "aws_instance" "web" {
  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Data Sources

- Permettent à Terraform d’utiliser des informations qu’il n’a pas définies

- Chaque provider Terraform peut offrir ses propres data sources


### Créer une configuration - Exercice

- Trouver la page de documentation Terraform de la ressource : aws_instance
 
- Copier le premier exemple dans un fichier `main.tf`

- Lancer la commande : `terraform init`

- Lancer la commande : `terraform plan`

- Lancer la commande `terraform apply`

- Voir le nouveau fichier créé `terraform.tfstate`

- Aller sur la console AWS et vérifier que la ressource est créée 



### Commentaires

Une ligne : `# or //`
Multiple ligne : `/* ... */`


### Variables d’entrée (1)

12 factor app:
  Il doit y avoir une séparation stricte entre la configuration et le code

- Paramètres pour personnaliser le code source

- Définition des valeurs à l’aide :
  - Des options CLI
  - Des variables d’environnement

- Possibilité de définir des règles de validation personnalisées 


### Variables d’entrée (2)

- Types :
  - string
  - number
  - bool
  - list/tuple : ["us-west-1a", "us-west-1c"]
  - map/object : {name = "Mabel", age = 52}
  - set

### Variables d’entrée (3)

dans fichier tf :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

variable "rg_name" {
  type        = string
  description = "Resource Group Name - Must be unique in a subscription"
  default     = "a-terraform-training-01"
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Command line

```bash
terraform plan/apply -var rg_name=a-terraform-training-03
```

Fichier de variables:

- Automatiques
    - terraform.tfvars
    - *.auto.tfvars
 
- Fichiers
```bash
terraform apply -auto-approve -var-file=file-var.tfvars
```

- environment variables
  
```bash
TF_VAR_<var-name>="a-value" terraform plan
eg.TF_VAR_rg_name="a-terraform-training-10" terraform plan
```bash

### Variables ordre de lecture

1. dans tf file
2. env var
3. terraform.tfvars
4. *.auto.tfvars
5. cmd line file vars (-var-file)
6. cmd line file var (-var)
```

### Variables : string par défaut

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
variable "rg_name" {
 type        = string
 description = "Resource Group Name"
 default     = "a-terraform-training-01"
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

est également équivalent à

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
variable "rg_name" {
 description = "Resource Group Name"
 default     = "a-terraform-training-01"
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Variables : string heredoc

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
variable "app_description" {
 type        = string
 description = "application description"
 default     = <<EOT
Welcome !
Application version is %%app_version
EOT
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Variables : number

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
variable "the_counter" {
 type        = number
 description = "# iteration"
 default     = 4
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Variables : bool

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
variable "trueOrFalse" {
 type        = bool
 description = "true or false"
 default     = true
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Variables : list

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
variable "eu_locations" {
 type        = list
 description = "location list"
 default     = ["westeurope","northeurope"]
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Variables : map

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
variable "hel" {
 type        = map
 description = "hel person"
 default     = {
   surname = "Hervé"
   name    = "Leclerc"
   role    = "CTO"
  }
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Variables : object

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
variable "whoishel" {
type        = object ({
  surname = string
  name    = string
  kids    = number
  skills  = list (string)
  }
)
description = "who is hel"
default     = {
  surname = "Hervé"
  name    = "Leclerc"
  kids    = 3
  skills  = [
              "kubernetes",
              "docker",
              "terraform"
            ]
}
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Variables - Exercice

- Créer le fichier variables.tf

- Créer le fichier formation.tfvars

- Variabiliser :
  - la région
  - l’instance type
  - tag Name


### Meta-arguments

- depends_on :
    - Dépendance Explicite vs Dépendance Implicite
    - depends_on = [“resource list”]
    - eg. depends_on = [ "azurerm_network_interface.nic1", "azurerm_managed_disk.dd1" ]


- count :
    - loop  count.index

Utile pour créer une simple condition if then avec count = var.something si quelque-chose = 0 la ressource ne sera pas créée/modifiée


- for_each :
    - loop on a list or map
chaque instance de for_each a un identifiant unique lors de la création ou de la modification de la configuration


- lifecycle :
    - Sur n'importe quel bloc
    - 3 arguments :
        - create_before_destroy (par défaut terraform détruire puis crée)
        - prevent_destroy (terraform lancera une erreur si une ressource est détruite !! impossible d'utiliser terraform destroy)
        - ignore_changes (si quelque chose est modifié en externe, terraform ne modifiera pas la ressource)

### Meta-arguments Exemple

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

resource "azurerm_resource_group" "rg_1" {
 name     = var.rg_01
 location = var.location
 tags     = var.tags
 lifecycle  {
   create_before_destroy = true
 }
}
resource "azurerm_resource_group" "rg_2" {
 name     = var.rg_02
 location = var.location
 tags     = var.tags
 lifecycle  {
   prevent_destroy = true
 }
}
resource "azurerm_resource_group" "rg_3" {
 name     = var.rg_03
 location = var.location
 tags     = var.tags
 lifecycle  {
   ignore_changes = [ tags,]
 }
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

### Outputs

- Valeurs de retour

- Utile pour exposer un sous-ensemble d’attributs de ressource à un module parent. 

- Utile pour afficher certaines valeurs dans la sortie CLI après avoir exécuté terraform apply

- Dans le cas de backend distant, les outputs du module racine sont accessibles par d'autres configurations via une source de données terraform_remote_state


### Outputs - Exercice 

- Créer le fichier outputs.tf

- Créer l’ouput “public_dns” 

- Exposer la valeur de l’attribut public_dns

- Exécuter la commande : terraform init

- Exécuter la commande : terraform plan 

- Exécuter la commande : terraform apply 

- Quelle commande affiche la valeur de l’output 


### Valeur locale

- Assigne un nom à une expression 

- Réutilisable dans la configuration

- Permet d’éviter la répétition 


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}

locals {
  service_name  = "redis"
  resilient = true
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Service = local.service_name
    Owner   = local.owner
  }
}

locals {
  # Ids for multiple sets of EC2 instances, merged together
  instance_ids = concat(aws_instance.blue.*.id, aws_instance.green.*.id)
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




### Fonctions intégrées (built-in)

- Terraform inclut un nombre de fonctions intégrées

- Il n’est pas possible de créer ses propres fonctions

- Familles de fonction 
    -  Numérique 
    -  Chaîne de caractères
    -  Collection
    -  Encodage 
    -  Système de fichier
    -  Date et heure
    -  Hachage et chiffrement 
    -  Réseau
    -  Conversion de types 
  
### Dynamic block

- Utilisé pour construire dynamiquement des blocs imbriqués reproductibles

- Fonctionne comme une boucle `for`


### Graphe des ressources

- Graphe des dépendances

- Généré par Terraform Core

- Construit à partir des fichiers de configuration

- Utilisé par Terraform pour : gérer les dépendances entre les ressources, la gestion du fichier d’état…

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}

terrafomrm graph

terraform graph | dot -Tsvg > graph.svg


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



### Modules

Un module est un "conteneur" pour plusieurs ressources qui sont utilisées ensemble


### Interpolation

Une syntaxe terraform spécifique pour référencer les attributs ou les arguments d'autres ressources (ou de soi-même)