

# Les Loops

### Loops avec Count et For Each


### 1
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

resource "null_resource" "simple" {
  count = 2
}
output "simple" {
  value = null_resource.simple
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### 2

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

locals {
  names = ["bob", "kevin", "stewart"]
}
resource "null_resource" "names" {
  count = length(local.names)
  triggers = {
    name = local.names[count.index]
  }
}
output "names" {
  value = null_resource.names
}


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### 3 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
locals {
  heights = {
    bob     = "short"
    kevin   = "tall"
    stewart = "medium"
  }
}

resource "null_resource" "heights" {
  for_each = local.heights
  triggers = {
    name   = each.key
    height = each.value
  }
}
output "heights" {
  value = null_resource.heights
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Loops avec Blocs Dynamiques (1)

Comment dynamiser un truc comme ca

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

resource "aws_security_group" "simple" {
  name        = "demo-simple"
  description = "demo-simple"
  ingress {
    description = "description 0"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "description 1"
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Loops avec Blocs Dynamiques (2)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
locals {
  ports = [80, 81]
}

resource "aws_security_group" "dynamic" {
  name        = "demo-dynamic"
  description = "demo-dynamic"
  dynamic "ingress" {
    for_each = local.ports
    content {
      description = "description ${ingress.key}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Loops avec Blocs Dynamiques (3)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
locals {
  rules = [{
    description = "description 0",
    port = 80,
    cidr_blocks = ["0.0.0.0/0"],
  },{
    description = "description 1",
    port = 81,
    cidr_blocks = ["10.0.0.0/16"],
  }]
}

resource "aws_security_group" "attrs" {
  name        = "demo-attrs"
  description = "demo-attrs"
   dynamic "ingress" {
    for_each = local.rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
output "map" {
  value = aws_security_group.map
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



### Nested Loops (1)

Tout st dans la structure des données

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

locals {
  groups = {
    example0 = {
      description = "sg description 0"
      rules = [{
        description = "rule description 0",
        port = 80,
        cidr_blocks = ["10.0.0.0/16"],
      },{
        description = "rule description 1",
        port = 81,
        cidr_blocks = ["10.1.0.0/16"],
      }]
    },
    example1 = {
      description = "sg description 1"
      rules = [{
        description = "rule description 0",
        port = 80,
        cidr_blocks = ["10.2.0.0/16"],
      },{
        description = "rule description 1",
        port = 81,
        cidr_blocks = ["10.3.0.0/16"],
      }]
    }
  }
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Nested Loops (2)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

resource "aws_security_group" "this" {
  for_each    = local.groups
  name        = each.key # top-level key is security group name
  description = each.value.description
  dynamic "ingress" {
    for_each = each.value.rules # List of Maps with rule attributes
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}

output "security_groups" {
  value = aws_security_group.this
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Nested Loops (3)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
locals {
  groups = {
    example0 = {
      description = "sg description 0"
    },
    example1 = {
      description = "sg description 1"
    }
  }
  rules = {
    example0 = [{
      description = "rule description 0",
      port = 80,
      cidr_blocks = ["10.0.0.0/16"],
    },{
      description = "rule description 1",
      port = 81,
      cidr_blocks = ["10.1.0.0/16"],
    }]
    example1 = [{
      description = "rule description 0",
      port = 80,
      cidr_blocks = ["10.2.0.0/16"],
    },{
      description = "rule description 1",
      port = 81,
      cidr_blocks = ["10.3.0.0/16"],
    }]
  }
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Nested Loops (4)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

resource "aws_security_group" "this" {
  for_each    = local.groups
  name        = each.key # top-level key is security group name
  description = each.value.description
  dynamic "ingress" {
    for_each = local.rules[each.key] # List of Maps with rule attributes
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}

output "security_groups" {
  value = aws_security_group.this
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### For In Loop Basics





