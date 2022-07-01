

# Aller plus loin

### CDKTF (CDK for Terraform)


Le kit de développement cloud pour Terraform (CDKTF) permet d'utiliser des langages de programmation très utilisés pour définir et provisionner l'infrastructure. 

Cela donne accès à l'ensemble de l'écosystème Terraform sans apprendre le langage de configuration HashiCorp (HCL).

Support actuel : TypeScript, Python, Java, C#, and Go (experimentale).


![](images/terraform/cdktf.png){height="300px"}


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


### Importer des ressources dans Terraform


1. terraform import [https://www.terraform.io/cli/import](https://www.terraform.io/cli/import)
2. terraformer: multi providers [https://github.com/GoogleCloudPlatform/terraformer](https://github.com/GoogleCloudPlatform/terraformer)
3. aztfy: spécialisé Azure [https://github.com/Azure/aztfy](https://github.com/Azure/aztfy)


Exemples:  

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

# terraform import

terraform import azurerm_resource_group.importrg \
/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/hel-training-terraform-tobe-imported


# terraformer
terraformer import azure -R awh-terraform-import-labs -o export  --resources="*"
  

# aztfy
aztfy -o terraform awh-terraform-import-labs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 


