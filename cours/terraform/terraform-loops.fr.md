

# Les Loops

### Loops avec `count` et `for_each`


### count (1) 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

resource "null_resource" "simple" {
  count = 2
}
output "simple" {
  value = null_resource.simple
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### count (2)

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


### count (3)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

variable "user_names" {
 description = "Matrix name"
 type        = list(string)
 default     = ["neo", "trinity", "morpheus"]
}

resource "null_resource" "for" {
 # Changes to any instance of the cluster requires re-provisioning
 triggers = {always_run = "${timestamp()}"}
 count = length(var.user_names)
 provisioner "local-exec" {
   command = "echo SON NOM EST = ${var.user_names[count.index]}"
 }
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### for_each (1)

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


### for_each (2)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

variable "car" {
 description = "Cars name"
 type        = list(string)
 default     = ["bmw", "mercedes", "maserati"]
}

resource "null_resource" "each" {
 # Changes to any instance of the cluster requires re-provisioning
 triggers = {always_run = "${timestamp()}"}
 for_each = toset(var.car)
 provisioner "local-exec" {
   command = "echo LA VOITURE EST = ${each.value}"
 }
}

output "all_cars" {
 value = null_resource.each
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### for_each (3)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
ariable "names" {
 description = "A list of names"
 type        = list(string)
 default     = ["neo", "trinity", "morpheus"]
}
output "upper_names" {
 value = [for name in var.names : upper(name)]
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
variable "hero_thousand_faces" {
 description = "map"
 type        = map(string)
 default     = {
   neo      = "hero"
   trinity  = "love interest"
   morpheus = "mentor"
 }
}
output "bios" {
 value = [for name, role in var.hero_thousand_faces : "${name} is the ${role}"]
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

### For In Loop Basics (1)


Pour faire de la manipulation de données

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
# List to List
locals {
  list = ["a","b","c"]
}
output "list" {
  value = [for s in local.list : upper(s)]
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
# Map to list
locals {
  list = {a = 1, b = 2, c = 3}
}
output "result1" {
  value = [for k,v in local.list : "${k}-${v}" ]
}
output "result2" {
  value = [for k in local.list : k ]
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

### For In Loop Basics (2)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
# List to Map
locals {
  list = ["a","b","c"]
}
output "result" {
  value = {for i in local.list : i => i }
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
# Map to Map
locals {
  list = {a = 1, b = 2, c = 3}
}
output "result" {
  value = {for k,v in local.list : k => v }
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### For In Loop Basics (3)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
# Filtrer une liste de nombre

locals {
  list = [1,2,3,4,5]
}
output "list" {
  value = [for i in local.list : i if i < 3]
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
# Filtrer une Map non consistente

locals {
  list = [
    {a = 1, b = 5},
    {a = 2},
    {a = 3},
    {a = 4, b = 8},
  ]
}
output "list" {
  value = [for m in local.list : m if contains(keys(m), "b") ]
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### For In Loop Basics (4)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
variable "hero_thousand_faces" {
  description = "map"
  type        = map(string)
  default     = {
    neo      = "hero"
    trinity  = "love interest"
    morpheus = "mentor"
  }
}
output "bios" {
  value = [for name, role in var.hero_thousand_faces : "${name} is the ${role}"]
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
locals {
  minions = [{
    name: "bob"
  },{
    name: "kevin",
  },{
    name: "stuart"
  }]
}
output "minions" {
  value = local.minions[*].name
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### For In Loop Basics (5)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
# Filter Map Elements
locals {
  list = [
    {a = 1, b = 5},
    {a = 2, b = 6},
    {a = 3, b = 7},
    {a = 4, b = 8},
  ]
}
output "list" {
  value = [for m in local.list : values(m) if m.b > 6 ]
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
locals {
  list = [
    "mr bob",
    "mr kevin",
    "mr stuart",
    "ms anna",
    "ms april",
    "ms mia",
  ]
}
output "list" {
  value = {for s in local.list : substr(s, 0, 2) => s...}
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Lookups, Keys, Contains

lookup récupère la valeur d'un seul élément d'une Map, en fonction de sa clé. Si la clé donnée n'existe pas, la valeur par défaut donnée est renvoyée à la place.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
locals {
  list = [{a = 1}, {b = 2}, {a = 3}]
}
output "list" {
  value = [for m in local.list : m if lookup(m, "a", null) != null ]
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
locals {
  list = [{a = 1}, {b = 2}, {a = 3}]
}
output "list" {
  value = [for m in local.list2 : m if contains(keys(m), "a") ]
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

