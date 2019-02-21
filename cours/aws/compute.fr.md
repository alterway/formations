# AWS Calcul

## EC2

### Qu'est-ce qu'Amazon EC2 ?

- Elastic Compute Cloud
- Offre une capacité de calcul évolutive dans le cloud Amazon Web Services (AWS)
- Environnements de calcul virtuels, appelés **instances** (équivalent du serveur ou de la machine virtuelle)

### AMI

- Amazon Machine Image
- Modèle préconfiguré pour les instances
- Doit être spécifiée pour lancer une instance
- Une AMI comprend les éléments suivants :
  - Un modèle pour le volume racine de l'instance (système d'exploitation, un serveur d'applications et des applications)
  - Les autorisations de lancement qui contrôlent les comptes AWS qui peuvent utiliser l'AMI pour lancer les instances
  - Un mappage de périphérique de stockage en mode bloc qui spécifie les volumes à attacher à l'instance lorsqu'elle est lancée

### Créer une AMI presonnalisée

- Lancer une instance à partir d'une AMI existante
- Personnaliser cette instance
- Enregistrer la configuration mise à jour comme AMI personnalisée

![Schéma Utilisation AMI](https://docs.aws.amazon.com/fr_fr/AWSEC2/latest/UserGuide/images/ami_lifecycle.png)



### Types d'instances

### Stockage d'instance

### Paires de clés

### EC2 et VPC

### Gestion à distance

### Metadata

### Balisage

## Infrastructure mondiale



## Auto Scaling / ELB




## Containers

