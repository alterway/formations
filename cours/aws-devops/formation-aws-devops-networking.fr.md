# AWS Networking

## VPC

### Définition d'un VPC

 - Virtual Private Cloud
 - Permet de mettre en service un réseau privé, isolé de manière logique
 - Sert à lancer des ressources AWS dans un réseau virtuel 
 - Maîtrise de l'environnement réseau virtuel

  - Sélection de plage d'adresses IP
  - Création de sous-réseaux 
  - Configuration de tables de routage et de passerelles réseau
  - IPv4 / IPv6
  - Un VPC par défaut par compte racine AWS

### VPCs et sous-réseaux

 - Un sous-réseau ou subnet définit une plage d'adresses IPs dans un VPC
 - Des ressources AWS peuvent être lancées dans un subnet sélectionné
 - ID unique, plage IP précise
 - Un **subnet privé** est utilisé pour des ressources qui n'ont pas besoin d'être accessible via internet
 - Un **subnet public** est utilisé pour des ressources qui seront accessible via internet. Dispose d'une route vers une Passerelle Internet
 - Chaque subnet est créé dans une AZ et ne peut s'étendre à plusieurs zones

### Adresses IP Elastic

 -  Adresse IPv4 publique statique
 - Peut être associée à n'importe quelle instance ou interface réseau
 - Peut être déplacée d'une instance à une autre
 - Limite de cinq adresses IP Elastic par compte

### Passerelle Internet 

 - Composant de VPC redondant et hautement disponible qui permet la communication entre des ressources dans un subnet public et Internet
 - Fournit une cible dans les tables de routage VPC pour le trafic routable sur Internet
 - Effectue la conversion d'adresse réseau (NAT) pour les instances auxquelles ont été affectées des adresses IPv4 publiques
 - Activation pour une instance:

  - Attacher une passerelle Internet au VPC
  - S'assurer que la table de routage du sous-réseau pointe sur la passerelle Internet
  - S'assurer que le contrôle d'accès et les règles des groupes de sécurité du réseau autorisent l'acheminement d'un trafic pertinent vers et en provenance de l'instance

### Passerelle NAT

 - Passerelle de traduction d'adresses réseau (NAT) pour autoriser les instances d'un sous-réseau privé à se connecter à Internet ou à d'autres services AWS
 - Pas de trafic IPv6
 - Création et association: 

  - Nécessite une adresse IP Elastic (EIP) à associer à la passerelle NAT
  - Mettre à jour la table de routage associée à un ou à plusieurs sous-réseaux privés pour pointer le trafic lié à Internet vers la passerelle NAT
  - Créée dans une zone de disponibilité spécifique

 - Instances NAT: dépréciées 

### Schéma

![Schéma VPC Passerelles](https://docs.aws.amazon.com/fr_fr/vpc/latest/userguide/images/nat-gateway-diagram.png)

### Groupes de sécurité

 - Un groupe de sécurité (security group) agit en tant que pare-feu virtuel pour les instances afin de contrôler le trafic entrant et sortant
 - Un groupe de sécurité par défaut est créé pour tout VPC
 - Il est possible d'affecter jusqu'à cinq groupes de sécurité pour une instance
 - Limites sur le nombre de groupes de sécurité par VPC, sur le nombre de règles par groupe de sécurité, et sur le nombre de groupes de sécurité par interface réseau
 - On peut indiquer des règles d'autorisation, mais pas des règles d'interdiction
 - Par défaut:

  - Pas de règles entrantes
  - Une règle sortante autorisant tout le trafic sortant

### ACL réseau

- Liste de contrôle d'accès (ACL) 
- Couche de sécurité facultative pour VPC
- Fait office de pare-feu pour le contrôle du trafic entrant et sortant d'un ou plusieurs sous-réseaux
- VPC automatiquement associé à une liste ACL réseau par défaut
- Par défaut, chaque liste ACL réseau personnalisée refuse tout trafic entrant et sortant 
- Liste numérotée (max 32766) de règles évaluées dans l'ordre, en commençant par le numéro le plus bas 
- Règles entrantes et sortantes distinctes
- Chaque règle peut autoriser ou refuser le trafic

### Tables de routage

 - Ensemble de règles appelées routes qui permettent de déterminer la direction du trafic réseau
 - Chaque sous-réseau doit être associé à une table de routage
 - Un sous-réseau peut être associé à une seule table de routage à la fois
 - Possible d'associer plusieurs sous-réseaux à la même table de routage

### Schéma

![Schéma VPC](https://docs.aws.amazon.com/fr_fr/vpc/latest/userguide/images/custom-route-table-diagram.png)

### VPC peering

 - Connexion pour mettre en réseau deux VPC
 - Permet de router le trafic entre les VPC de manière privée (sans passer par internet)
 - Peut se créer pour des VPC sur le même compe AWS ou entre VPCs de différents comptes


## Amazon Route 53

### Qu'est-ce qu'Amazon Route 53 ?

 - Système de noms de domaine (DNS) hautement disponible d'AWS
 - 
 - 53 pour le numéro de port de DNS
 - Enregistrement de noms de domaine
 - Achemine le trafic Internet vers les ressources du domaine
 - Vérifie l'état de santé des ressources

### Acheminement du trafic Internet vers un site web ou une application

![Schéma rout 53 traffic](https://docs.aws.amazon.com/fr_fr/Route53/latest/DeveloperGuide/images/how-route-53-routes-traffic.png)

### Enregistrement de domaine

 - Choisir un nom de domaine et confirmer qu'il est disponible
 - Enregistrement le nom de domaine Route 53 avec les noms et les informations sur le contact pour le propriétaire du domaine
 - Création automatique d'une **hosted zone**

### Hosted zone ou zone hébergée

 - Conteneur d'enregistrements des informations sur la gestion du trafic pour un domaine
  - Serveurs de noms
  - Alias
  - Adresses IP
  - Enregistrements DNS (AAAA, CNAME, SRV, MX, etc)
  - Sous domaines
  - Stratégies de routage

### Stratégies de routage

 - Déterminent la façon dont Amazon Route 53 répond aux requêtes pour un enregistrement donné
 - Stratégie de routage simple
 - Stratégie de routage par basculement: basculement actif-passif
 - Stratégie de routage par géolocalisation: achemine le trafic en fonction de l'emplacement de l'utilisateur
 - Stratégie de routage par proximité géographique : achemine du trafic en fonction de l'emplacement des ressources/détourne le trafic des ressources d'un emplacement donné vers un autre
 - Stratégie de routage avec latence : achemine le trafic vers la région qui fournit la meilleure latence
 - Stratégie de routage de réponse multivaleur : Route 53 répond aux requêtes DNS avec jusqu'à huit enregistrements sains sélectionnés de manière aléatoire.
 - Stratégie de routage pondéré : achemine le trafic vers plusieurs ressources selon les proportions spécifiée

### Schéma

![Schéma Routage par proximité géographique](https://docs.aws.amazon.com/fr_fr/Route53/latest/DeveloperGuide/images/geoproximity-routing-bias.png)

### Vérification de l'intégrité des ressources

 - Permet de : 
  - Vérifier si un point de terminaison spécifié, tel qu'un serveur web, est sain
  - Etre averti quand un point de terminaison tombe
  - Configurer également le basculement DNS, qui permet de rediriger le trafic Internet à partir d'une ressource non saine vers une ressource saine

![Schéma Healthcheck Route53](https://docs.aws.amazon.com/fr_fr/Route53/latest/DeveloperGuide/images/how-health-checks-work.png)


## Direct Connect

### Concept Direct Connect 

 - Relie le réseau interne d'une entreprise à un emplacement AWS Direct Connect via un lien physique (fibre optique)
 - Un emplacement AWS Direct Connect donne accès à AWS dans la région à laquelle il est associé
 
 ![Schéma Direct connect](https://docs.aws.amazon.com/fr_fr/directconnect/latest/UserGuide/images/direct_connect_overview.png)

 
