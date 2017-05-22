############
## VPC
############

resource "aws_vpc" "swarm" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.vpc_name}"
    Owner = "${var.owner}"
  }
}

# DHCP Options are not actually required, being identical to the Default Option Set
resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name = "${var.region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name = "${var.vpc_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id ="${aws_vpc.swarm.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}

##########
# Keypair
##########

resource "aws_key_pair" "default_keypair" {
  key_name = "${var.default_keypair_name}"
  public_key = "${var.default_keypair_public_key}"
}


############
## Subnets
############

# Subnet (public)
resource "aws_subnet" "swarm" {
  vpc_id = "${aws_vpc.swarm.id}"
  cidr_block = "${var.vpc_cidr}"
  availability_zone = "${var.zone}"

  tags {
    Name = "swarm"
    Owner = "${var.owner}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.swarm.id}"
  tags {
    Name = "swarm"
    Owner = "${var.owner}"
  }
}

############
## Routing
############

resource "aws_route_table" "swarm" {
    vpc_id = "${aws_vpc.swarm.id}"

    # Default route through Internet Gateway
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.gw.id}"
    }

    tags {
      Name = "swarm"
      Owner = "${var.owner}"
    }
}

resource "aws_route_table_association" "swarm" {
  subnet_id = "${aws_subnet.swarm.id}"
  route_table_id = "${aws_route_table.swarm.id}"
}


############
## Security
############

resource "aws_security_group" "swarm" {
  vpc_id = "${aws_vpc.swarm.id}"
  name = "swarm"

  # Allow all outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP from control host IP
  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["${var.control_cidr}"]
  }

  # Allow all internal
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # Allow all traffic from the API ELB
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_security_group.swarm_api.id}"]
  }

  # Allow all traffic from control host IP
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.control_cidr}"]
  }

  tags {
    Owner = "${var.owner}"
    Name = "swarm"
  }
}
