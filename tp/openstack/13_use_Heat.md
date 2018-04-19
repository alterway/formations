# TP : Utiliser OpenStack Heat

## Objectifs

* Découvrir le service d'orchestration Heat
* Manipuler des ressources IaaS au travers de Heat
* Découvrir l'infrastructure as code

## Démarche

Sur un cloud OpenStack fonctionnel (cloud public, cloud privé déjà existant, DevStack, etc.) :

### Écrire un template au format HOT

Infrastructure à déployer :

 * Une instance "serveur web"
 * Un volume de stockage du site web (statique)
 * Dans un réseau dédié
 * Réseau connecté au réseau externe
 * Accès depuis l'extérieur au travers d'une IP flottante

