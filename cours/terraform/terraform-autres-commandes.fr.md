

# Autres Commandes utiles

### terraform `validate`

- Validation statique de la configuration

- Ne fait pas d’appels API

- Validation syntaxique

- Bonne pratique : exécuter cette commande automatiquement dans les systèmes de CI/CD

🔴 Ne peut être exécutée sans initialisation


### terraform validate - Exercice

- Tester la commande :  terraform validate

- Commenter l’instance_type dans le fichier formation.tfvars

- Exécuter de nouveau la commande terraform validate

- Décommenter la ligne précédemment commentée 


### terraform `fmt`


- Formate les fichiers de configuration

- Applique certaines conventions de style Terraform https://www.terraform.io/docs/language/syntax/style.html 


🟢  **Objectif** : Améliorer la lisibilité 


Configuration VSCode 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.json}

"terraform-ls.terraformExecPath": "/usr/local/bin/terraform",
  "[terraform]": {
    "editor.defaultFormatter": "hashicorp.terraform",
    "editor.formatOnSave": true
  },
  "terraform-ls.experimentalFeatures": {
    "validateOnSave": true
  }

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### terraform `import`

- Sert à importer des ressources existantes dans l’état Terraform

- Après l’import, Terraform peut les manager

🟠 Il faut saisir tous les paramètres nécessaires pour la ressource. Tester avec un `terraform plan` jusquà obtenir un plan qui ne contient pas de changement.


### Verbosité des logs


- TF_LOG

- TF_LOG_CORE

- TF_LOG_PROVIDER

- Niveaux :
    - TRACE
    - DEBUG
    - INFO
    - WARN
    - ERROR


### Verbosité des logs - Exercice

- Dans formation.tfvars, modifier la valeur de l’instance_type

- Dans le fichier .env, ajouter :  `export TF_LOG_PROVIDER=TRACE` et lancer un terraform plan

- Répéter l’opération en modifiant la valeur de `TF_LOG_PROVIDER` à `DEBUG`, `INFO`, `WARN` et `ERROR`

- Remettre la valeur de l’instance_type dans le fichier formation.tfvars

- Supprimer la dernière ligne ajoute au fichier `.env`



### terraform `workspace`

- Les données stockées dans un backend appartiennent à un workspace

- Le backend par défaut se nomme “default”

- Possibilité d’avoir plusieurs backends 


### terraform `state`

- Commande utilisée pour gérer l’état Terraform

- Elle a plusieurs sous-commandes


### terraform state - Exercice

Exécuter les commandes suivantes :

`terraform state list`

`terraform state show aws_instance.web`


### terraform `taint` `untaint`

La commande `terraform taint` permet de marquer manuellement une ressource comme étant "à problème", ce qui signifie qu'elle sera détruite et recréée lors de la prochaine application de terraform. 

`terraform untaint` permet de supprimer cette condition "à problème" de la ressource.


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
$ terraform state list

azurerm_network_interface.nic
azurerm_network_security_group.nsg
azurerm_public_ip.pip
azurerm_resource_group.demo-rg
azurerm_subnet.demo-subnet
azurerm_virtual_machine_extension.ext
azurerm_virtual_network.demo-vnet
azurerm_windows_virtual_machine.vm


$ terraform taint azurerm_windows_virtual_machine.myvm

Resource instance azurerm_windows_virtual_machine.myvm has been marked as tainted.

 # azurerm_windows_virtual_machine.vm is tainted, so must be replaced
-/+ resource "azurerm_windows_virtual_machine" "myvm" {
      ~ computer_name              = "demo-mytestvm" -> (known after apply)
      - encryption_at_host_enabled = false -> null
...
Plan: 2 to add, 0 to change, 2 to destroy.

$ terraform untaint azurerm_windows_virtual_machine.myvm

Resource instance azurerm_windows_virtual_machine.myvm has been successfully untainted.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### terraform `show`

- Affiche l’état de manière lisible pour un humain

![](images/terraform/terraform-show.png){height="350px"}


### terraform `refresh`

Terraform intérroge toutes les resources distantes présentes dans le fichier d'état et le synchronise avec les valeurs des attributs distants. Cette commande ne modifie par les valeurs des attributs distants seul le fichier d'état est modifié (tfstate).

Attention cette commande a été déclarée comme obsolète et sera supprimée dans une future version de terraform car elle n'est pas sûre.