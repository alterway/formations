

# Aller plus loin

### CDKTF (CDK for Terraform)


Le kit de développement cloud pour Terraform (CDKTF) permet d'utiliser des langages de programmation très utilisés pour définir et provisionner l'infrastructure. 

Cela donne accès à l'ensemble de l'écosystème Terraform sans apprendre le langage de configuration HashiCorp (HCL).

Support actuel : TypeScript, Python, Java, C#, and Go (experimentale).


![]([images/terraform/tfsec.png](https://mktg-content-api-hashicorp.vercel.app/api/assets?product=terraform-cdk&version=v0.10.4&asset=website%2Fdocs%2Fcdktf%2Fterraform-platform.png)){height="300px"}


Pour démarrer : [https://learn.hashicorp.com/tutorials/terraform/cdktf-install?in=terraform/cdktf](https://learn.hashicorp.com/tutorials/terraform/cdktf-install?in=terraform/cdktf)

### CDKTF (Exemple)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
#!/usr/bin/env python
from constructs import Construct
from cdktf import App, TerraformStack, TerraformOutput, Token
from cdktf_cdktf_provider_azurerm import AzurermProvider, ResourceGroup, VirtualNetwork

class MyConf(TerraformStack):
    def __init__(self, scope: Construct, ns: str):
        super().__init__(scope, ns)

        location="northeurope"
        rg_name="hel-cdktf-rg"
        vnet_name="hel-cdktf-vnet"
        vnet_address_space=["10.0.0.0/16"]
        tag = {
                "env": "dev",
                "projet": "cdktf-test",
                "who": "herve leclerc"
              }
        AzurermProvider(self, "Azurerm",\
            features={}
            )
        hel_cdktf_rg = ResourceGroup(self, 'hel-cdktf-rg',\
                                     name     = rg_name,
                                     location = location,
                                     tags     = tag
                                    )
        hel_cdktf_vnet = VirtualNetwork(self, 'hel-cdktf-vnet',\
            depends_on          = [hel_cdktf_rg],
            name                = vnet_name,
            location            = location,
            address_space       = vnet_address_space,
            resource_group_name =Token().as_string(hel_cdktf_rg.name),
            tags = tag
            )
        TerraformOutput(self, 'vnet_id',
            value=hel_cdktf_vnet.id
        )

app = App()
MyConf(app, "cdktf")

app.synth()

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~





### checkov

- Analyse statique de la configuration

- Peut scanner les infrastructures provisionnées avec Terraform pour détecter les erreurs de configuration

- Intègre 400 polices qui suivent les bonnes pratiques de sécurité et de conformité 

- [https://github.com/bridgecrewio/checkov ](https://github.com/bridgecrewio/checkov)


### checkov

![](images/terraform/checkov.png){height="500px"}

### terratest

- Librairie Go

- Facilite l’écriture de tests 

- Fournit des fonctions et des patterns

- Fonctionnalités 
    - Test de code Terraform
    - Test de templates Packer
    - Test d’images Docker
    - Prise en charge d’API AWS
    - Prise en charge de l’API Kubernetes
    - Requêtes HTTP

### Terraform compliance

- Framework de test

- Permet de tester son code avant de le déployer 

- Behavior Driven Development (BDD)


### Terraform compliance (1)

![](images/terraform/compliance3.png)

### Terraform compliance (2)

![](images/terraform/compliance1.png){height="500px"}

### Terraform compliance (3)

![](images/terraform/compliance2.png){height="500px"}

