############################
# Swarm Master nodes
############################

resource "aws_instance" "master" {

    count = "${var.nb_swarm_master}"
    ami = "${lookup(var.amis_swarm, var.region)}"
    instance_type = "${var.master_instance_type}"

    iam_instance_profile = "${aws_iam_instance_profile.swarm.id}"

    subnet_id = "${aws_subnet.swarm_private.id}"
    private_ip = "${cidrhost(var.private_subnet1_cidr, 20 + count.index)}"
    associate_public_ip_address = false
    source_dest_check = false

    availability_zone = "${var.zone}"
    vpc_security_group_ids = ["${aws_security_group.swarm_master.id}"]
    key_name = "${var.default_keypair_name}"

    tags {
      Owner = "${var.owner}"
      Name = "master-${count.index}"
      ansibleFilter = "${var.ansibleFilter}"
      ansibleNodeType = "master"
      ansibleNodeName = "master${count.index}"
    }
}

############
## Security
############

resource "aws_security_group" "swarm_master" {
  vpc_id = "${aws_vpc.swarm.id}"
  name = "swarm-master-sg"

  # Allow inbound traffic to the port used by swarm API HTTPS
  ingress {
    from_port = 1000
    to_port = 65000
    protocol = "TCP"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["${var.public_subnet1_cidr}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.private_subnet1_cidr}"]
  }

  # Allow all outbound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Owner = "${var.owner}"
    Name = "swarm-master-sg"
  }
}


output "swram_masters_private_ip" {
  value = "${join(",", aws_instance.master.*.private_ip)}"
}
