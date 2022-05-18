# Le workflow Terraform

### Workflow principal Terraform


![](images/terraform/terraform-workflow.png){height="300px"}


### Devops Loop

- init : initialise l'environnement Terraform (local). Habituellement exécuté une seule fois par session.

- plan : compare l'état de Terraform avec l'état tel quel dans le cloud, créé et affiche un plan d'exécution. Cela ne change pas le déploiement (lecture seule)

- apply : appliquer le plan de la phase de planification. Cela modifie potentiellement le déploiement (lecture et écriture).

- destroy : Détruire toutes les ressources régies par cet environnement de terraformation spécifique.


![](images/terraform/devops-loop.png){height="300px"}


