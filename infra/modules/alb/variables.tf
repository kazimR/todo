variable "lb_name" {
  type    = string
}

variable "public_subnets_ids" {
  type    = list(string)
}

variable "security_groups_ids" {
   type    = list(string)
 }


