# TP : Utiliser Ansible

## Objectifs

* Découvrir l'outil de déploiement de configuration Ansible
* Utiliser Ansible comme une suite à l'étape d'orchestration
* Exploiter un inventaire dynamique pour OpenStack

## Démarche

Sur un cloud OpenStack fonctionnel (cloud public, cloud privé déjà existant, DevStack, etc.), dans lequel tournent déjà des instances :

### Installer Ansible

Via APT ou le système de paquets Python.

### Tester l'inventaire dynamique

Rapatrier le script d'inventaire dynamique pour OpenStack depuis `https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/openstack_inventory.py`.

Avec un `clouds.yaml` configuré, l'exécution du script d'inventaire dynamique doit retourner un inventaire au format JSON comprenant les instances présentes dans le cloud.

### Écrire un playbook

Utiliser cet inventaire pour déployer au travers d'un *playbook* Ansible un serveur web sur les instances ainsi qu'une page `index.html` "Hello world".

