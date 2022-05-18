

# Bonnes Pratiques

### Structure d’un projet Terraform

Projet simple :

```bash
.
├── .gitignore
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── resources.tf
├── provider.tf
├── terraform.tfvars
├── modules/
│   ├── module1/
│   │   ├── README.md
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
```

- Le fichier `main.tf` qui est le fichier principal d’un projet terraform
- Le fichier `provider.tf` pour y définir les fournisseurs
- Le fichier `variables.tf` pour les variables principales
- Le fichier `terraform.tfvars` pour les variables secrètes qui ne sera pas stocké dans votre repository git
- Le fichier de variables `*.auto.tfvars` variables qui sont lues automatiquement
- Le fichier `outputs.tf` pour y définir tout ce qui sera affiché
- Les fichiers `resources.tf` pour un petit projet un simple fichier `resources.tf` suffira. Il est possible d'en créer d'autre avec des noms explicites.
- Les modules
- Le fichier .gitignore voir slide suivante

### Fichier .gitignore

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log

# Exclude all .tfvars files, which are likely to contain sentitive data, such as
# password, private keys, and other secrets. These should not be part of version
# control as they are data points which are potentially sensitive and subject
# to change depending on the environment.
#
*.tfvars

# Ignore override files as they are usually used to override resources locally and so
# are not checked in
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Include override files you do wish to add to version control using negated pattern
#
# !example_override.tf

# Include tfplan files to ignore the plan output of command: terraform plan -out=tfplan
# example: *tfplan*

# Ignore CLI configuration files
.terraformrc
terraform.rc

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Plus de bonnes pratiques

![](images/terraform/best-practices.jpeg){height="300px"}

[https://git.alterway.fr/dt/terraform/best-practices](https://git.alterway.fr/dt/terraform/best-practices)


### Modules invocation

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
module "service_foo" {
  source = "/modules/microservice"
  image_id = "ami-12345"
  num_instances = 3
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

module "rancher" {
    source = "https://github.com/objectpartners/tf-modules//rancher/server-standalone-elb-db&ref=9b2e590"
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Sources

![](images/terraform/non-merci-trop-occupes.png){height="200px"}


- [https://github.com/terraform-aws-modules](https://github.com/terraform-aws-modules)
  
- [https://github.com/terraform-azurerm-modules](https://github.com/terraform-azurerm-modules)
  
- [https://github.com/google-terraform-modules](https://github.com/google-terraform-modules)
  
- [https://github.com/terraform-alicloud-modules](https://github.com/terraform-alicloud-modules)
    

### Modules - Exercice

- Créer un dossier modules/ec2

- Créer les fichiers data.tf, instance.tf, variables.tf et outputs.tf

- Transférer la configuration du fichier main.tf dans le module

- Appeler ce nouveau module créé dans main.tf

