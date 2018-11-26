# AWS IAM

### Vue d'ensemble

IAM: Identity Access Management

 - Gestion des accès aux services et ressources AWS
 - Création et gestion des utilisateurs et des groupes
 - Gestion des rôles et autorisations
 - Gestion des utilisateurs fédéréq et leurs permissions

## Utilisateurs et groupes

### Utilisateurs

 - Authentification console : Username/Password
 - Authentification CLI, SDKs et APIs: Access key/Secret key

### Groupes

 - Regoupement d'utilisateurs
 - Simplifie la gestion des permissions et r^les pour plusieurs utilisateurs

## Policies

### Une policy IAM c'est quoi?

 - Ensemble d'autorisations IAM
 - Allow/Deny une ou des actions sur une ou plusieurs ressources
 - Format JSON décrivant les permissions
 - Peut être assignée à 
   - Des users
   - Des groupes 
   - Des rôles 
   - Des ressources
 - AWS Policy Generator
 - AWS Policy Validator
 - AWS Policy Simulator
 - Managed Policies : AWS-managed, Customer-managed
 - Inline policies


### Contenu d'une policy IAM
 
 - Version
 - Id
 - Statement
 - Sid
 - Effect
 - Princial
 - Actions
 - Ressources

### Exemple de policy 

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

## Roles IAM

### Rôles IAM: définition

 - Permettent déléguer l'accès à des users, applications et services qui, en temps normal, n'ont pas accès aux ressources AWS
 - Permettent d'éviter de partager des informations d'identification ou de définire des autorisations pour chaque entité afin faire des appels d'API AWS 
 - Un rôle IAM est associé une policy IAM
 - Pas de credentials associés à un rôle
 - Le service utilisant un rôle IAM se voit attribué dynamiquement une paire d'Access key/Secret key temporaire

### Exemple concret

 - Une Instance EC2 hébergeant une application Python et qui a besoin d'accéder à des fichiers stockés sur Amazon S3 
 - Méthode 1: embarquer l'Access Key et le Secret key dans le code 
 - Méthode 2: stocker les AK/SK dans un fichier de configuration
 - Ces approches posent un sérieux problème de sécurité
 - Meilleure stratégie: Assigner un rôle IAM à l'instance

### Instance profile

Image

 - Paramètre pouvant contenir plusieurs rôles à endosser par l'instance EC2
 - Dans cet exemple, on attribue le rôle PythonInEC2AccessS3 à l'instance EC2

### Attribution de credentials temporaires 

 - L'application Python est installée sur l'instance (Avec AWS SDK for Python)
 - Pour accéder au stockage S3, Python utilise le service metadata de l'instance pour obtenir des credentials temporaires (valables durant 15 minutes à 36 heures)
 - L'application accède au compartiment spécifié dans le rôle
 PythonInEC2AccessS3

### Best practices IAM

 - Supprimer les AK du compte racine AWS
 - Créer des comptes IAM individuels
 - Utiliser les groupes pour assigner des permissions
 - Principe du moindre privilège
 - Configurer une politique de mots de passe forts (complexité, longueur)
 - Activer le MFA
 - Utiliser les rôles pour les applications hébergées sur AWS
 - Déléguer des rôle plutôt que de partager des credentials
 - Faire tourner / renouveler les credentials régulièrement
 - Supprimer les users et les credentials inutilisés
 - Utiliser les conditions dans les policies pour un niveau supplémentaire de sécurité
 - Monitorer l'activité des comptes AWS