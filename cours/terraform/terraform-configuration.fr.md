

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


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}

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


### Variables d’entrée (1)

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


### Variables - Exercice

- Créer le fichier variables.tf

- Créer le fichier formation.tfvars

- Variabiliser :
  - la région
  - l’instance type
  - tag Name


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

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Fonctions intégrées (built-in)

- Terraform inclut un nombre de fonctions intégrées

- Il n’est pas possible de créer ses propres fonctions

- Familles de fonction 
  * Numérique 
  * Chaîne de caractères
  * Collection
  * Encodage 
  * Système de fichier
  * Date et heure
  * Hachage et chiffrement 
  * Réseau
  * Conversion de types 
  
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