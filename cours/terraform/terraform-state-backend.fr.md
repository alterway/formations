# Formation Terraform - Les états et les backends

### Qu’est-ce que le fichier d’état ?


- Utilisé par Terraform pour y stocker l’état de l’infrastructure et de la configuration qu’il gère

- Stocké par défaut dans un fichier local `terraform.tfstate`

- Pour être stocké à distance

- Utile pour créer des plans et apporter des modifications à l’infrastructure


### Qu’est-ce qu’un backend ?

- Un backend sert à définir :
    -  Où les opérations sont effectuées 
    -  Où les fichiers d’état sont stockés

- Une opération est une requête API pour créer, lire, mettre à jour ou supprimer une ressource

- Deux types de backends 
    -  Local 
    -  Distant

### Backend local

- Backend par défaut 

- Ne requiert aucune configuration

- Le fichier d’état est stocké dans un fichier texte dans le répertoire courant 

- **À proscrire en production**

### Backend distant

- À privilégier

- Permet l’utilisation d’un espace de stockage distant pour stocker le fichier d’état

- Facilite le travail en équipe

- Exemples de backend distants :
    -  Etcd
    -  Consul
    -  HTTP
    -  S3

### State locking (Verrouillage d’état)

- Se produit à chaque opération qui écrit dans le fichier d’état

- Évite la corruption de l’état 

- Évite  que plusieurs opérations d’écriture s’exécutent en simultanées

- Possibilité de désactiver le verrouillage (**non recommandé**) 

- Tous les backends ne prennent pas en compte le verrouillage du fichier d’état


### Gestion des secrets dans le fichier d’état


- Cas du fichier d’état local :
  - Données stockées dans des fichiers JSON en texte brut

- Cas fichier d’état distant :
  - L’état n’est conservé en mémoire que lorsqu’il est utilisé par Terraform
  - Possibilité de chiffrement sur le répertoire distant selon le backend utilisé


