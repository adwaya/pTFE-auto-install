##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}

data "aws_availability_zones" "available" {}


# NETWORKING #

resource "aws_vpc" "hashicorp-tfe" {
  cidr_block           = "${var.network_address_space}"
  enable_dns_hostnames = "true"

  tags {
          Name = "Hashicorp TFE Demo VPC"
  }

}


resource "aws_subnet" "tfe_subnet" {
  vpc_id                  = "${aws_vpc.hashicorp-tfe.id}"
  cidr_block              = "${cidrsubnet(var.network_address_space, 8, 1)}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
          Name = "TFE Subnet"
  }

}

# ROUTING #


resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.hashicorp-tfe.id}"

}

resource "aws_route_table" "rtb" {
  vpc_id = "${aws_vpc.hashicorp-tfe.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

    tags {
        Name = "IGW"
    }

}

resource "aws_route_table_association" "tfe_subnet" {
  subnet_id      = "${aws_subnet.tfe_subnet.*.id[0]}"
  route_table_id = "${aws_route_table.rtb.id}"

}

# SECURITY GROUPS #
# TFE security group

resource "aws_security_group" "tfe" {
  name        = "tfe"
  vpc_id      = "${aws_vpc.hashicorp-tfe.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # TFE access from anywhere
  ingress {
    from_port   = 8800
    to_port     = 8800
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


# INSTANCES #

resource "aws_instance" "tfe_node" {
  count                       = "${var.tfe_node_count}"
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.large"
  subnet_id                   = "${aws_subnet.tfe_subnet.id}"
  private_ip                  = "${cidrhost(aws_subnet.tfe_subnet.cidr_block, count.index + 100)}"
  associate_public_ip_address = "true"
  vpc_security_group_ids      = ["${aws_security_group.tfe.id}"]
  key_name                    = "${var.key_name}"
  tags {
         Name = "${format("tfe-%02d.${var.dns_domain}", count.index + 1)}"
  }

}
