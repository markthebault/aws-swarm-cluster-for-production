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

# resource "aws_key_pair" "default_keypair" {
#   key_name = "${var.default_keypair_name}"
#   public_key = "${var.default_keypair_public_key}"
# }


############
## Subnets
############

# Subnet (public)
resource "aws_subnet" "swarm_public" {
  vpc_id = "${aws_vpc.swarm.id}"
  cidr_block = "${var.public_subnet1_cidr}"
  availability_zone = "${var.zone}"

  tags {
    Name = "swarm-public-subnet"
    Type = "Public subnet"
    Owner = "${var.owner}"
  }
}

# Subnet (private)
resource "aws_subnet" "swarm_private" {
  vpc_id = "${aws_vpc.swarm.id}"
  cidr_block = "${var.private_subnet1_cidr}"
  availability_zone = "${var.zone}"

  tags {
    Name = "swarm-private-subnet"
    Type = "Private subnet"
    Owner = "${var.owner}"
  }
}




#Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.swarm.id}"
  tags {
    Name = "swarm-igw"
    Owner = "${var.owner}"
  }
}

#Nat Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}
resource "aws_nat_gateway" "gw" {
  subnet_id  = "${aws_subnet.swarm_public.id}"
  allocation_id = "${aws_eip.nat_eip.id}"
  depends_on = ["aws_internet_gateway.gw"]
}

############
## Routing
############

#Public subnet
resource "aws_route_table" "swarm_public" {
    vpc_id = "${aws_vpc.swarm.id}"

    # Default route through Internet Gateway
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.gw.id}"
    }

    tags {
      Name = "swarm-public-route"
      Owner = "${var.owner}"
    }
}

resource "aws_route_table_association" "swarm_public" {
  subnet_id = "${aws_subnet.swarm_public.id}"
  route_table_id = "${aws_route_table.swarm_public.id}"
}

#Private subnet
resource "aws_route_table" "swarm_private" {
    vpc_id = "${aws_vpc.swarm.id}"

    # Default route through Internet Gateway
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_nat_gateway.gw.id}"
    }

    tags {
      Name = "swarm-private-route"
      Owner = "${var.owner}"
    }
}

resource "aws_route_table_association" "swarm_private" {
  subnet_id = "${aws_subnet.swarm_private.id}"
  route_table_id = "${aws_route_table.swarm_private.id}"
}
