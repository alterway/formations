

# Cheat Sheet Commandes

### Command Line tricks


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

# Autocompletion (requière un nouveau login )

terraform -install-autocomplete

# complete -o nospace -C /opt/homebrew/bin/terraform terraform

# Mise à jour des modules 

terraform get -update=true

# terraform console pour tester des expressions

echo 'join(",",["foo","bar"])' | terraform console

echo "aws_instance.my_ec2.public_ip" | terraform console 


# Source : https://res.cloudinary.com/acloud-guru/image/fetch/c_thumb,f_auto,q_auto/https://acg-wordpress-content-production.s3.us-west-2.amazonaws.com/app/uploads/2020/11/terraform-cheatsheet-from-ACG.pdf

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

