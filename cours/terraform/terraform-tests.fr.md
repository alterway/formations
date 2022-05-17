

# Terraform - Tests

### tfsec

- Outil d’analyse statique

- Détection de potentiels problèmes de sécurité
- Vérifie si 
    - Des données sensibles sont incluses dans la configuration Terraform
    - Les bonnes pratiques sont respectées
    - Analyse les modules locaux
    - Évalue les expressions ainsi que les valeurs littérales 
    - Évalue les fonctions Terraform 
    - https://github.com/aquasecurity/tfsec 




![](images/terraform/tfsec.png){height="300px"}


### checkov

- Analyse statique de la configuration

- Peut scanner les infrastructures provisionnées avec Terraform pour détecter les erreurs de configuration

- Intègre 400 polices qui suivent les bonnes pratiques de sécurité et de conformité 

- https://github.com/bridgecrewio/checkov 


### terratest

- Librairie Go

- Facilite l’écriture de tests 

- Fournit des fonctions et des patterns

- Fonctionnalités 
    - Test de code Terraform
    - Test de templates Packer
    - Test d’images Docker
    - Prise en charge d’API AWS
    - Prise en charge de l’API Kubernetes
    - Requêtes HTTP

### Terraform compliance

- Framework de test

- Permet de tester son code avant de le déployer 

- Behavior Driven Development (BDD)

