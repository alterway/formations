

# Les Conditons

### Exemples ternaires

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

output "a1" {
  value = true ? "is true" : "is false"
}

output "a2" {
  value = false ? "is true" : "is false"
}

output "a3" {
  value = 1 == 2 ? "is true" : "is false"
}


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Exemples de conditions avec built-in functions

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

output "b1" {
  value = contains(["a","b","c"], "d") ? "is true" : "is false"
}
output "b2" {
  value = keys({a: 1, b: 2, c: 3}) == ["a","b","c"] ? "is true" : "is false"
}
output "b3" {
  value = contains(keys({a: 1, b: 2, c: 3}), "b") ? "is true" : "is false"
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Exemples de conditions avec count 


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

variable "create1" {
  default = true
}
resource "random_pet" "pet1" {
  count = var.create1 ? 1 : 0
  length = 2
}
output "pet1" {
  value = random_pet.pet1
}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
variable "enable_autoscaling" {
  description = "If set to true, enable auto scaling"
  type        = bool
}

resource "aws_autoscaling_schedule" "scale_out_business_hours" {
  count = var.enable_autoscaling ? 1 : 0
  scheduled_action_name  = "scale-out-during-business-hours"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 10
  recurrence             = "0 9 * * *"
  autoscaling_group_name = aws_autoscaling_group.example.name
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


