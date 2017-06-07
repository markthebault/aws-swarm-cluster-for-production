
resource "aws_instance" "bastion"{
  ami = "${lookup(var.ami_bastion, var.region)}"
  instance_type = "${var.bastion_instance_type}"


  subnet_id = "${aws_subnet.swarm_public.id}"
  private_ip = "${cidrhost(var.public_subnet1_cidr, 7)}"
  associate_public_ip_address = true # Instances have public, dynamic IP

  availability_zone = "${var.zone}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
  key_name = "${var.default_keypair_name}"

  tags {
    Owner = "${var.owner}"
    Name = "bastion"
    ansibleFilter = "bastion"
    ansibleNodeType = "bastion"
    ansibleNodeName = "bastion"
  }

}

###################
## SECURITY GROUP
###################
resource "aws_security_group" "bastion" {
  vpc_id = "${aws_vpc.swarm.id}"
  name = "bastion-sg"

  # Allow vpc ICMP
  ingress {
    from_port = -1
    to_port = -1
    protocol = "ICMP"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # Allow privatesubnet inside trafic
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.private_subnet1_cidr}"]
  }

  # Allow inbound SSH traffic
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["${var.control_cidr}"]
  }

  # Allow openvpn traffic on UDP port 1194
  ingress {
    from_port = 1194
    to_port = 1194
    protocol = "UDP"
    cidr_blocks = ["${var.control_cidr}"]
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
    Name = "bastion-sg"
  }
}


output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}
