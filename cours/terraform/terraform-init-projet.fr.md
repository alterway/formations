

# Initialisation

### Initialiser le projet Terraform

- Créer le fichier providers.tf



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.puppet .numberLines}
terraform {
  required_version = ">=1.0.1"
  
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">=3.65.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "localstacktest"
  secret_key                  = "localstacktestkey"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_use_path_style           = true
  endpoints {
    ec2 = "http://192.168.64.11:31566"
    iam = "http://192.168.64.11:31566"
  }
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

