# TP : Utiliser Terraform

## Objectifs

* Découvrir l'outil d'orchestration Terraform
* Manipuler des ressources IaaS au travers de Terraform
* Découvrir l'infrastructure as code

## Démarche

Sur un cloud OpenStack fonctionnel (cloud public, cloud privé déjà existant, DevStack, etc.) :

### Écrire un template au format Terraform

Infrastructure à déployer :

 * Un nombre variable d'instances "serveur web"
 * Un volume de stockage du site web (statique)
 * Dans un réseau dédié
 * Réseau connecté au réseau externe
 * Accès depuis l'extérieur au travers d'une IP flottante

