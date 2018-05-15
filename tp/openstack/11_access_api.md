# TP : Se connecter aux APIs OpenStack

## Objectifs

* Comprendre et manipuler le concept d'API
* Découvrir le mode de fonctonnement des APIs OpenStack

## Démarche

Sur un cloud OpenStack fonctionnel (cloud public, cloud privé déjà existant, DevStack, etc.) :

### HTTP

Avec un outil comme curl, et à l'aide de la documentation des APIs, écrire les requêtes et les exécuter pour :

* Récupérer un token et afficher la catalogue de service auprès de Keystone
* Lister les volumes disponibles dans Cinder

### Client CLI

 * Installer `openstackclient`

Via APT sur un OS Ubuntu récent. Sinon via le système de paquets Python :

    apt install python-dev virtualenv
    virtualenv venv
    cd venv && source venv/bin/activate
    pip install python-openstackclient

 * Configurer `openstackclient` en créant un fichier `clouds.yaml`

Se baser sur un exemple de la documentation.

 * Réaliser les meês opérations que précédemment, mais avec `openstackclient`
 * Rajouter l'option `--debug`

### Dashboard web

Découvrir le dashboard web Horizon.

