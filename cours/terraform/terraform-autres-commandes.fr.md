

# Autres Commandes utiles

### terraform `validate`

- Validation statique de la configuration

- Ne fait pas d’appels API

- Validation syntaxique

- Bonne pratique : exécuter cette commande automatiquement dans les systèmes de CI/CD

- Ne peut être exécutée sans initialisation


### terraform validate - Exercice

- Tester la commande :  terraform validate

- Commenter l’instance_type dans le fichier formation.tfvars

- Exécuter de nouveau la commande terraform validate

- Décommenter la ligne précédemment commentée 


### terraform `fmt`


- Formate les fichiers de configuration

- Applique certaines conventions de style Terraform https://www.terraform.io/docs/language/syntax/style.html 


**Objectif** : améliorer la lisibilité 


### terraform `import`

- Sert à importer des ressources existantes dans l’état Terraform

- Après l’import, Terraform peut les manager


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


### terraform `show`

- Affiche l’état de manière lisible pour un humain


### terraform `destroy`

- Détruit toutes les ressources gérées par Terraform

- Utile surtout pour les environnements éphémères 


