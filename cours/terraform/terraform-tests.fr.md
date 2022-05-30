

# Terraform Tests

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

- [https://github.com/bridgecrewio/checkov ](https://github.com/bridgecrewio/checkov)


### checkov

![](images/terraform/checkov.png){height="500px"}

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


### Terraform compliance (1)

![](images/terraform/compliance3.png)

### Terraform compliance (2)

![](images/terraform/compliance1.png){height="500px"}

### Terraform compliance (3)

![](images/terraform/compliance2.png){height="500px"}



### Terraform tests (All In One) (1)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
image:
  name: alterway/terraform-azure-cli:1.3
  entrypoint:
    - "/usr/bin/env"
    - "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

variables:
  GITLAB_TF_ADDRESS: ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/${CI_PROJECT_NAME}
  PLAN: plan.tfplan
  PLAN_JSON: tfplan.json
  TF_ROOT: ${CI_PROJECT_DIR}
  CI_DEBUG_TRACE: "false"
cache:
  paths:
    - .terraform

.before_script_template: &before_script_definition
  - apk --no-cache add jq
  - cd ${TF_ROOT}
  - az login --service-principal -u ${ARM_CLIENT_ID} -p ${ARM_CLIENT_SECRET} --tenant ${ARM_TENANT_ID}
  - alias convert_report="jq -r '([.resource_changes[]?.change.actions?]|flatten)|{\"create\":(map(select(.==\"create\"))|length),\"update\":(map(select(.==\"update\"))|length),\"delete\":(map(select(.==\"delete\"))|length)}'"
  - terraform --version
  - terraform init -backend-config="address=${GITLAB_TF_ADDRESS}" -backend-config="lock_address=${GITLAB_TF_ADDRESS}/lock" -backend-config="unlock_address=${GITLAB_TF_ADDRESS}/lock" -backend-config="username=gitlab-ci-token" -backend-config="password=${CI_JOB_TOKEN}" -backend-config="lock_method=POST" -backend-config="unlock_method=DELETE" -backend-config="retry_wait_min=5"

stages:
  - validate
  - build
  - compliance
  - test
  - deploy

validate:terraform:
  image:
    name: alterway/terraform-azure-cli:1.3
    entrypoint:
      - "/usr/bin/env"
      - "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  stage: validate
  before_script:
    - *before_script_definition
  script:
    - terraform validate

validate:checkov:
  image:
    name: bridgecrew/checkov
    entrypoint:
      - "/usr/bin/env"
      - "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  stage: validate
  script:
    - checkov -d .

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Terraform tests (All In One) (2)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

validate:tfsec:
  image:
    name: liamg/tfsec
    entrypoint:
      - "/usr/bin/env"
      - "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  stage: validate
  script:
    - if [ -f "terraform.tfvars" ]; then tfsec --tfvars-file terraform.tfvars .; else tfsec .; fi

plan:
  stage: build
  variables:
    ENV: "prod"
  before_script:
    - *before_script_definition
  script:
    - terraform plan -var-file=$ENV/$ENV.vars -out=$PLAN
    - terraform show -json $PLAN | jq -r '([.resource_changes[]?.change.actions?]|flatten)|{"create":(map(select(.=="create"))|length),"update":(map(select(.=="update"))|length),"delete":(map(select(.=="delete"))|length)}' > $PLAN_JSON
  artifacts:
    name: plan
    paths:
      - ${TF_ROOT}/plan.tfplan
    reports:
      terraform: ${TF_ROOT}/tfplan.json

compliance:terraform:
  stage: compliance
  image:
    name: eerkunt/terraform-compliance
    entrypoint:
      - "/usr/bin/env"
      - "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  script:
    - ls -la
    - pwd
    - terraform init -backend-config="address=${GITLAB_TF_ADDRESS}" -backend-config="lock_address=${GITLAB_TF_ADDRESS}/lock" -backend-config="unlock_address=${GITLAB_TF_ADDRESS}/lock" -backend-config="username=gitlab-ci-token" -backend-config="password=${CI_JOB_TOKEN}" -backend-config="lock_method=POST" -backend-config="unlock_method=DELETE" -backend-config="retry_wait_min=5"
    - terraform show -json $PLAN > $PLAN.out.json
    - terraform-compliance -f features -p $PLAN.out.json

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Terraform tests (All In One) (3)


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
apply:
  stage: deploy
  environment:
    name: prod
  variables:
    ENV: "prod"
  before_script:
    - *before_script_definition
  script:
    - terraform apply -input=false $PLAN
  dependencies:
    - plan
  when: manual
  only:
    - master
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


