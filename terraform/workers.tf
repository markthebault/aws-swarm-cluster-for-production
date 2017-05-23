
############################################
# Swarm worker nodes
############################################

resource "aws_instance" "worker" {
    count = 3
    ami = "${lookup(var.amis_swarm, var.region)}"
    instance_type = "${var.worker_instance_type}"

    subnet_id = "${aws_subnet.swarm_private.id}"
    private_ip = "${cidrhost(var.private_subnet1_cidr, 30 + count.index)}"
    associate_public_ip_address = false
    source_dest_check = false # TODO Required??

    availability_zone = "${var.zone}"
    vpc_security_group_ids = ["${aws_security_group.swarm_worker.id}"]
    key_name = "${var.default_keypair_name}"

    tags {
      Owner = "${var.owner}"
      Name = "worker-${count.index}"
      ansibleFilter = "${var.ansibleFilter}"
      ansibleNodeType = "worker"
      ansibleNodeName = "worker${count.index}"
    }
}


############
## Security
############
resource "aws_security_group" "swarm_worker" {
  vpc_id = "${aws_vpc.swarm.id}"
  name = "swarm-worker-sg"

  # Allow inbound traffic to the port used by swarm API HTTPS
  ingress {
    from_port = 1000
    to_port = 65000
    protocol = "TCP"
    cidr_blocks = ["${var.public_subnet1_cidr}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["${var.public_subnet1_cidr}"]
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
    Name = "swarm-worker-sg"
  }
}


output "swram_workers_private_ip" {
  value = "${join(",", aws_instance.worker.*.private_ip)}"
}
