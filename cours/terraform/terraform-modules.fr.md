

# Modules Terraform

### Qu’est-ce qu’un module Terraform ?

- Conteneur qui regroupe plusieurs ressources Terraform  ensemble

- Peut être appelé à plusieurs endroits et à plusieurs reprises

- Évite la duplication de code

- Facilite la maintenance

- Favorise la réutilisabilité de définitions communes



### Types de modules

- Local

- Distant
    - Terraform registry : https://registry.terraform.io/browse/modules 
    - GitLab, Github…
    - Terraform Cloud
    - Terraform Enterprise private module registries 
    - URLs HTTP



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

![](images/terraform/non-merci-trop-occupes.png){height="250px"}


- (https://github.com/terraform-aws-modules)
  
- (https://github.com/terraform-azurerm-modules)
  
- (https://github.com/google-terraform-modules)
  
- (https://github.com/terraform-alicloud-modules)
    

### Modules - Exercice

- Créer un dossier modules/ec2

- Créer les fichiers data.tf, instance.tf, variables.tf et outputs.tf

- Transférer la configuration du fichier main.tf dans le module

- Appeler ce nouveau module créé dans main.tf

