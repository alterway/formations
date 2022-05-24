# Les états et les backends

### Qu’est-ce que le fichier d’état ?


- Utilisé par Terraform pour y stocker l’état de l’infrastructure et de la configuration qu’il gère
- Stocké par défaut dans un fichier local `terraform.tfstate`
- Pour être stocké à distance
- Utile pour créer des plans et apporter des modifications à l’infrastructure

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
{
  "version": 4,
  "terraform_version": "1.1.9",
  "serial": 56,
  "lineage": "0b723a72-0399-a30e-7933-514a923eed6f",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "aws_dynamodb_table",
      "name": "main",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": []
    },
    {
      "mode": "managed",
      "type": "aws_iam_instance_profile",
      "name": "ec2_profile",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "arn": "arn:aws:iam::000000000000:instance-profile/ec2_profile",
            "create_date": "2022-05-17T17:14:27Z",
            "id": "ec2_profile",
            "name": "ec2_profile",
            "name_prefix": null,
            "path": "/",
...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



### Qu’est-ce qu’un backend ?

- Un backend sert à définir :
    -  Où les opérations sont effectuées 
    -  Où les fichiers d’état sont stockés

- Une opération est une requête API pour créer, lire, mettre à jour ou supprimer une ressource

- Deux types de backends 
    -  Local 
    -  Distant

### Backend local

- Backend par défaut 

- Ne requiert aucune configuration

- Le fichier d’état est stocké dans un fichier texte dans le répertoire courant 


🔴 **À proscrire en production**

### Backend distant (1)

- À privilégier

- Permet l’utilisation d’un espace de stockage distant pour stocker le fichier d’état

- Facilite le travail en équipe

- Exemples de backend distants :
    -  Etcd
    -  Consul
    -  HTTP
    -  S3


### Backend distant (2)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
terraform {
  backend "gcs" {
    bucket  = "tf-state-prod"
    prefix  = "terraform/state"
  }
}
terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}
terraform {
  backend "azurerm" {
    resource_group_name  = "StorageAccount-ResourceGroup"
    storage_account_name = "abcd1234"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



### State locking (Verrouillage d’état)

- Se produit à chaque opération qui écrit dans le fichier d’état

- Évite la corruption de l’état 

- Évite  que plusieurs opérations d’écriture s’exécutent en simultanées

- Possibilité de désactiver le verrouillage (**non recommandé**) 

🔴 Tous les backends ne prennent pas en compte le verrouillage du fichier d’état


### Gestion des secrets dans le fichier d’état


- Cas du fichier d’état local :
  - Données stockées dans des fichiers JSON en texte brut

- Cas fichier d’état distant :
  - L’état n’est conservé en mémoire que lorsqu’il est utilisé par Terraform
  - Possibilité de chiffrement sur le répertoire distant selon le backend utilisé


