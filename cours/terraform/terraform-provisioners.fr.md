

# Provisioners

### local-exec provisioner

- Invoque un exécutable local après la création de la ressource

- Invoque un processus sur la machine exécutant Terraform et non la ressource

- Son utilisation ne doit se fait qu’en dernier recours 


### remote-exec provisioner

- Invoque un script sur la ressource distance, après sa création

- Peut être utilisé pour lancer un outil de configuration, une initialisation...



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

resource "aws_instance" "web" {
  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


