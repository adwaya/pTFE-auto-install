##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {
  default = "my_aws_key"
}

variable "dns_domain" {
  default = "mydomain.xyz"
}

variable "network_address_space" {
  default = "192.168.0.0/16"
}

variable "ssh_user" {
#  default = "ec2-user"
  default = "ubuntu"
}

variable "tfe_node_count" {
  default = 1
}

