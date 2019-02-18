# Identity Access Managment (IAM)

### IAM: Présentation

IAM: Identity Access Management

  - Gestion des accès aux services et ressources AWS
  - Création et gestion des utilisateurs et des groupes
  - Gestion des rôles et autorisations
  - Gestion des utilisateurs fédéréq et leurs permissions

### IAM Users: users

  - Authentification console : Username/Password
  - Authentification CLI, SDKs et API: Access key/Secret key

### IAM Users: groups

  - Regroupement d'utilisateurs IAM
  - Simplifie la gestion des permissions et roles pour plusieurs utilisateurs


### IAM Policies: définition

  - Ensemble d'autorisations IAM
  - Allow/Deny une ou des actions sur une ou plusieurs ressources
  - Format JSON décrivant les permissions
  - Peut être assignée à:
    - Des users
    - Des groupes 
    - Des rôles 
    - Des ressources

### IAM Policies: types de policies

  - Managed Policies:
    - Managées par AWS
    - Managées par les utilisateurs
  - Inline policies


### IAM Policies: propriétés
 
  - Version
  - Id
  - Statement
  - Sid
  - Effect
  - Princial
  - Actions
  - Ressources

### IAM Policies: exemple

```
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "s3:ListAllMyBuckets"
         ],
         "Resource":"arn:aws:s3:::*"
      }
   ]
}

```

### IAM Roles: définition

  - Permettent déléguer l'accès à des users, applications et services qui, en temps normal, n'ont pas accès aux ressources AWS
  - Permettent d'éviter de partager des informations d'identification ou de définire des autorisations pour chaque entité afin faire des appels d'API AWS 
  - Un rôle IAM est associé une policy IAM
  - Pas de credentials associés à un rôle
  - Le service utilisant un rôle IAM se voit attribué dynamiquement une paire d'Access key/Secret key temporaire

### IAM Roles: exemple

  - Une Instance EC2 hébergeant une application Python et qui a besoin d'accéder à des objets stockés sur Amazon S3
  - Méthode 1: embarquer l'Access Key (AK) et le Secret Key (SK) dans la
    configuration de l'application
  - Méthode 2: attribuer un role à l'instance EC2 portant l'application
  - La méthode 2 sera préférée car évite d'exposer des credentials et donc une
    potentielle faille de sécurité

### IAM: Best practices

  - Créer des comptes IAM individuels
  - Utiliser les groupes pour assigner des permissions
  - Toujours attribuer le minimum de privilège possible
  - Configurer une politique de mots de passe forts (complexité, longueur)
  - Activer le MFA pour les utilisateurs IAM

### IAM: Best practices

  - Utiliser les rôles pour les applications hébergées sur AWS EC2
  - Déléguer des rôle plutôt que de partager des credentials (cross-accounts)
  - Etablir une politique de renouvellement des credentials régulier
  - Supprimer les users et les credentials inutilisés
  - Utiliser les conditions dans les policies pour un niveau supplémentaire de sécurité
  - Monitorer l'activité des comptes AWS


