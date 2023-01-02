variable "env" {
  type = string
  default = "test"
}

variable "user" {
  type = string
  default = "kazim"
}

variable "company" {
  type = string
  default = "wt"
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/20"
}

variable "public_subnets_cidr" {
  type    = list(string)
  default = ["10.0.0.0/22","10.0.4.0/23", "10.0.6.0/23"]
}

variable "private_subnets_cidr" {
  type    = list(string)
  default = ["10.0.8.0/22","10.0.12.0/23", "10.0.14.0/23"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-1a","eu-west-1b","eu-west-1c"]
}
