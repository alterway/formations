# Réseau

## Virtual Private Cloud (VPC)

### VPC: Présentation

  - Virtual Private Cloud
  - Ressources cloud isolées
  - Permet le contrôle de l'environnement de mise en réseau
  - Peut être connecté à des centres de données existants via VPN ou Direct Connect
  - Peut être appairé à d'autres VPC dans AWS

### VPC et subnets

  - Géographiquement:
    - AWS global
    - Region
    - Availability Zone (AZ)
  - Virtuellement:
    - VPC
    - Subnet

### VPC et subnets

  - VPC: CIDR block compris entre /16 et /28
  - Subnet: CIDR block compris entre /16 et /28

Évitons les problèmes, restons sur la [RFC1918](https://tools.ietf.org/html/rfc1918) !

### VPC et subnets

![Subnets dans un VPC](images/schema_vpc_subnets.png){height="400px"}

### Accès internet

  - En l'état, il n'y a pas d'accès internet, il faut donc mettre en place:
    - [Internet Gateway (IGW)](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html): subnets publics
    - [Passerelle NAT (NAT GW)](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html): subnets privés

### Accès internet

![VPC avec subnets privés et publics](images/schema_vpc_subnets_gw.png){height="400px"}

### Internet Gateway

  - Composant de VPC redondant et hautement disponible qui permet la communication entre des ressources dans un VPC et Internet
  - Fournit une cible dans les tables de routage VPC pour le trafic routable sur Internet

  Besoins:

  - Table de routage
  - Attacher l'IGW au VPC
  - Attribuer une IP publique à l'instance
  - Ne pas bloquer les flux (ACL et Security Group)

### NAT Gateway

  - Passerelle NAT managée et scalable
  - Création et association:
    - Nécessite une adresse Elastic IP (EIP) à associer à la passerelle NAT
    - Mettre à jour la table de routage associée à un ou à plusieurs sous-réseaux privés pour router le trafic lié à Internet vers la passerelle NAT

### Security Groups

  - Gestion des flux niveau 4 (modèle OSI)
  - Gestion des règle par autorisation (à opposition à l'interdiction des ACL)
  - Un groupe de sécurité par défaut est créé pour tout VPC
  - Par défaut:
    - En entrée: __rien__ n'est autorisé
    - En sortie: __tout__ est autorisé

### Tables de routage

  - Tables de routage (L4) classiques pour router le réseau dans le VPC
  - Chaque subnet est associé à une table de routage (sinon les paquets ne sont pas routé)
  - Un sous-réseau peut être associé à une seule table de routage à la fois
  - Possible d'associer plusieurs subnets à la même table de routage

### Tables de routage

![Tables de routage](images/schema_vpc_subnets_routes.png){height="400px"}

### VPC peering

  - Interconnexion entre VPC
  - Permet de router le trafic entre les VPC de manière privée (sans passer par internet)
  - Peut se créer pour des VPC sur le même compe AWS ou entre VPCs de différents comptes
  - Possibilité de faire du Peering transitif grace à [VPC Transit Gateway](https://aws.amazon.com/transit-gateway/)

## Amazon Route 53

### Présentation

  - Service DNS managé
  - Registrar
  - Service de heath checks

### Stratégies de routage

  - Plusieurs stratégies de routage DNS:
    - __Simple routing policy__
    - __Failover routing policy__: failover actif-passif
    - __Geolocation routing policy__
    - __Geoproximity routing policy__
    - __Latency routing policy__
    - __Multivalue answer routing policy__: réponse aléatoire de Route 53 dans un choix de 8 records (au plus)
    - __Weighted routing policy__: notamment pour l'A/B testing


