# TP : Utiliser OpenStack

## Objectifs

* Découvrir les fonctionnalités basiques IaaS d'OpenStack
* Manipuler des ressources IaaS
* Utiliser les outils pour intéragir avec les APIs OpenStack

## Démarche

Sur un cloud OpenStack fonctionnel (cloud public, cloud privé déjà existant, DevStack, etc.) :

### Pré-requis

Si nécessaire, installer `openstackclient` et le configurer avec un fichier `clouds.yaml`.

### Au travers d'un outil CLI ou du dashboard web

 * Créer un réseau (niveau 2)
 * Créer un sous-réseau (niveau 3)
 * Créer un routeur dont la passerelle externe est un réseau externe
 * Connecter le routeur au sous-réseau précédemment créé

Optionnel :
 * Créer une image dans Glance

 * Lister les images existantes
 * Lister les flavors existantes

 * Créer une nouvelle clé SSH

 * Créer une instance à partir d'une image et d'une flavor, en spécifiant le réseau précédemment créé et la clé SSH précédemment enregistrée
 * Vérifier que l'instance apparait `ACTIVE`, afficher les logs

 * Allouer une adresse IP flottante
 * L'associer à l'instance

 * Essayer de joindre par `ping`/SSH l'instance au travers de son IP flottante
 * Adapter les groupes de sécurité et leurs règles pour corriger les problèmes éventuels

 * Se connecter en SSH à l'instance
 * Se connecter à l'API de metadata `http://169.254.169.254`

