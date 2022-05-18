

# Provisioners

### local-exec provisioner

- Invoque un exécutable local après la création de la ressource

- Invoque un processus sur la machine exécutant Terraform et non la ressource

- Son utilisation ne doit se fait qu’en dernier recours 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

variable "owner" {
  description = "the owner of this project"
  default     = "ruan"
}

resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "echo ${var.owner} > file_${null_resource.this.id}.txt"
    interpreter = ["bash", "-c"]
  }
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



### remote-exec provisioner

- Invoque un script sur la ressource distance, après sa création

- Peut être utilisé pour lancer un outil de configuration, une initialisation...

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

resource "aws_instance" "web" {
  # ...

  provisioner "remote-exec" {
    inline = [
      "dnf -y install epel-release",
      "dnf -y install htop",
    ]
  }
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


-
### file provisioner

- Le provisioner file est utilisé pour copier des fichiers ou des répertoires de la machine exécutant Terraform vers la ressource nouvellement créée.


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

resource "aws_instance" "web" {
  # ...

  # Copies the myapp.conf file to /etc/myapp.conf
  provisioner "file" {
    source      = "conf/myapp.conf"
    destination = "/etc/myapp.conf"
  }
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Provisionners all in one

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

resource "null_resource" "example_provisioner" {
  triggers = {
    public_ip = aws_instance.example_public.public_ip
  }

  connection {
    type  = "ssh"
    host  = aws_instance.example_public.public_ip
    user  = var.ssh_user
    port  = var.ssh_port
    agent = true
  }

  // copy our example script to the server
  provisioner "file" {
    source      = "files/get-public-ip.sh"
    destination = "/tmp/get-public-ip.sh"
  }

  // change permissions to executable and pipe its output into a new file
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/get-public-ip.sh",
      "/tmp/get-public-ip.sh > /tmp/public-ip",
    ]
  }

  provisioner "local-exec" {
    # copy the public-ip file back to CWD, which will be tested
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_user}@${aws_instance.example_public.public_ip}:/tmp/public-ip public-ip"
  }
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 