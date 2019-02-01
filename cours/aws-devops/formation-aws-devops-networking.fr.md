# AWS Networking

## VPC

### Présentation 

- Virtual Private Cloud
- Ressources cloud isolées
- Permet le contrôle de l'environnement de mise en réseau
- Peut être connecté à des centres de données existants via VPN ou Direct Connect
- Peut être appairé à d'autres VPC dans AWS

### VPC et subnets

- AWS global
- Region
- Availability Zone (AZ)

- VPC
- Subnet

### VPC et subnets

- VPC: CIDR block compris entre /16 et /28
- Subnet: CIDR block compris entre /16 et /28

Evitons les problèmes, restons sur le [RFC1918](https://tools.ietf.org/html/rfc1918) !

### VPC et subnets

![Schéma VPC et subnet](https://static.osones.com/images/aws/vpc/schema_vpc_subnets.png)

### Accès internet

- Jusque là, pas d'accès internet, il faut donc:
  - Internet Gateway (IGW): subnets publics
  - Passerelle NAT (NAT GW): subnets privés

### Accès internet

![Schéma VPC, subnets et accès internet](https://static.osones.com/images/aws/vpc/schema_vpc_subnets_gw.png)

### Internet Gateway

- Composant de VPC redondant et hautement disponible qui permet la communication entre des ressources dans un VPC et Internet
- Fournit une cible dans les tables de routage VPC pour le trafic routable sur Internet

Besoins:

- Table de routage
- Attacher l'IGW au VPC
- Attribuer une IP publique à l'instance
- Ne pas bloquer les flux (ACL et Security Group)

### Passerelle NAT

- Passerelle NAT managée
- Création et association:
  - Nécessite une adresse Elastic IP (EIP) à associer à la passerelle NAT
  - Mettre à jour la table de routage associée à un ou à plusieurs sous-réseaux privés pour pointer le trafic lié à Internet vers la passerelle NAT

### Security Groups

- Gestion des flux niveau 4 (modèle OSI)
- Gestion des règle par autorisation (à opposition à l'interdiction des ACL)
- Un groupe de sécurité par défaut est créé pour tout VPC
- Par défaut:
  - En entrée: rien n'est autorisé
  - En sortie: tout est autorisé

### Tables de routage

- Tables de routage (L4) classiques pour router le réseau dans le VPC
- Chaque subnet est associé à une table de routage (sinon les paquets ne sont pas routé)
- Un sous-réseau peut être associé à une seule table de routage à la fois
- Possible d'associer plusieurs subnets à la même table de routage

### Tables de routage

![Schéma VPC](https://docs.aws.amazon.com/fr_fr/vpc/latest/userguide/images/custom-route-table-diagram.png)

### VPC peering

- Interconnexion entre VPC
- Permet de router le trafic entre les VPC de manière privée (sans passer par internet)
- Peut se créer pour des VPC sur le même compe AWS ou entre VPCs de différents comptes


## Amazon Route 53

### Présentation

- Service DNS managé
- Registrar
- Service de heath checks

### Stratégies de routage

- Déterminent la façon dont Amazon Route 53 répond aux requêtes pour un enregistrement donné
  - Simple routing policy
  - Failover routing policy: failover actif-passif
  - Geolocation routing policy
  - Geoproximity routing policy
  - Latency routing policy
  - Multivalue answer routing policy: réponse aléatoire de Route 53 dans un choix de 8 records (au plus)
  - Weighted routing policy: notamment pour l'A/B testing

