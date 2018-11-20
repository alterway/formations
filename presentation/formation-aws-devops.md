# Cloud / DevOps / AWS

Durée : 3 jours

## Description

Cette formation vous permettra de comprendre les principes fondamentaux et les notions de base du Cloud. Vous verrez également des scénarios d'utilisation et d’automatisation qui vous permettront d'avoir une vision claire et complète du Cloud Computing et de l'Infrastructure as a Service (IaaS). Ensuite cette formation proposera une approche centrée sur AWS et vous permettre de passer de la théorie à la pratique.

IaaS est un modèle où les ressources d'infrastructure (telles que calcul, stockage et réseau) sont mises à disposition des utilisateurs par le biais d'APIs. Les APIs permettent l'accès à ces ressources par de multiples moyens : interface graphique/web, ligne de commande, script, programme, etc. Cette possibilité de programmer l'allocation, l'utilisation et la restitution des ressources fait la force du système cloud : mise à l'échelle automatique en fonction de la demande, facturation à l'usage, etc. Les processus deviennent plus agiles. Des clouds publics tels qu'Amazon Web Services (AWS) proposent de l'IaaS. Dans le domaine du cloud privé, c'est le logiciel libre OpenStack qui fait référence.

### Objectifs

* Comprendre les concepts et le vocabulaire liés au cloud
* Comprendre la différence entre le cloud et la virtualisation
* Comprendre les bénéfices du cloud
* Vue d'ensemble des acteurs cloud du marché et focus sur AWS
* Comprendre l'interface web d'AWS et overview des principaux services
* Comprendre le modèle de consommation des ressources via les API
* Comprendre le concept d'infrastructure as code
* Comprendre les concepts de déploiement et d'intégration continue

### Public visé

La formation s'adresse aux administrateur système souhaitant monter en compétence sur AWS et adopter un mouvement devops

### Pré-requis

* Base d'administration système Linux

## Programme

### Le cloud

1. Définition du cloud par le NIST
2. Définitions : IaaS / PaaS / SaaS
3. Définition cloud public / cloud privé
4. La différence entre cloud et virtualisation
5. Les APIs, la clé du cloud
6. Plus value du cloud, pourquoi le cloud

#### Overview du marché du cloud

1. Les acteurs cloud
2. Focus AWS leader cloud public

#### Concepts IaaS

1. Instance
2. Stack
3. Metadata
4. Cloud init
5. Images cloud
6. Stockage block et objet

#### Best practice d’usage

1. Infra as Code : automatisation et reproductibilité
2. Application cloud ready
3. Scalabilité horizontale

#### Cloud inside

1. SDN
2. SDS
3. Virtualisation vs. bare metal
4. Le stockage dans le cloud : SDS
5. La gestion du réseau SDN et NFV

### AWS

#### IAM

1. Utilisateurs
2. Roles
3. Policies

#### Networking

1. VPC
2. Route53
3. Direct Connect

#### Calcul

1. EC2
2. Infrastructure mondiale
3. Auto Scaling / ELB
4. Containers

#### Stockage

1. S3
2. EBS
3. EFS
4. Base de données

#### CI/CD

1. CodeBuild
2. CodeDeploy
3. CodePipeline
4. CodeCommit
5. CloudFormation

#### Autres services managés

1. Diffusion de contenu
2. Big Data
3. Serverless
4. Messagerie
5. Audit et securité
6. Autres

#### Mise en pratique

Mise en œuvre de travaux pratiques afin de prendre en main la console AWS ainsi que les principaux services. L'objectif est de partir d'une architecture relativement simple non résiliente pour ensuite construire une architecture hautement disponible en terme de compute, network et stockage en s'appuyant sur les service AWS disponibles. Nous verrons également qu'il est possible de piloter et réaliser ces architectures en CLI (awscli) via les API AWS.

### Infrastructure as code

#### Concepts

1. Pourquoi ?
2. Notions de stack
3. Bonnes pratiques
4. CloudFormation
5. Terraform / Packer

#### Mise en pratique

En reprenant les exercices précédents, nous verrons qu'il est possible déployer des applications hautement disponibles sans même toucher la console AWS, cela grâce à l'infrastructure as code et à l'utilisation d'outils tels que CloudFormation ou Terraform. Ces "stacks" seront ensuite réutilisables et versionnées.

### Déploiement et intégration continue

1. Bonnes pratiques
2. Semantic versionning
3. Workflow Git
4. Tests
5. Déploiement

#### Mise en pratique

Grâce aux outils d'infrastructure as code, couplés avec des services AWS tel que CodeBuild et CodePipeline, nous verrons qu'il est possible de complètement automatiser le déploiement d'applications à partir d'un simple commit. Nous déploierons deux types d'applications :
- Site web statique sur S3
- Application dynamique (PHP ou Node) via Elastic Beanstalk

EOD
