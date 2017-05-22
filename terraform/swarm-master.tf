############################
# Swarm Master nodes
############################

resource "aws_instance" "master" {

    count = 3
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "${var.master_instance_type}"

    iam_instance_profile = "${aws_iam_instance_profile.swarm.id}"

    subnet_id = "${aws_subnet.swarm.id}"
    private_ip = "${cidrhost(var.vpc_cidr, 20 + count.index)}"
    associate_public_ip_address = true # Instances have public, dynamic IP
    source_dest_check = false # TODO Required??

    availability_zone = "${var.zone}"
    vpc_security_group_ids = ["${aws_security_group.swarm.id}"]
    key_name = "${var.default_keypair_name}"

    tags {
      Owner = "${var.owner}"
      Name = "master-${count.index}"
      ansibleFilter = "${var.ansibleFilter}"
      ansibleNodeType = "master"
      ansibleNodeName = "master${count.index}"
    }
}

###############################
## swarm API Load Balancer
###############################

resource "aws_elb" "swarm_api" {
    name = "${var.elb_name}"
    instances = ["${aws_instance.master.*.id}"]
    subnets = ["${aws_subnet.swarm.id}"]
    cross_zone_load_balancing = false

    security_groups = ["${aws_security_group.swarm_api.id}"]

    listener {
      lb_port = 6443
      instance_port = 6443
      lb_protocol = "TCP"
      instance_protocol = "TCP"
    }

    health_check {
      healthy_threshold = 2
      unhealthy_threshold = 2
      timeout = 15
      target = "HTTP:8080/healthz"
      interval = 30
    }

    tags {
      Name = "swarm"
      Owner = "${var.owner}"
    }
}

############
## Security
############

resource "aws_security_group" "swarm_api" {
  vpc_id = "${aws_vpc.swarm.id}"
  name = "swarm-api"

  # Allow inbound traffic to the port used by swarm API HTTPS
  ingress {
    from_port = 6443
    to_port = 6443
    protocol = "TCP"
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
    Name = "swarm-api"
  }
}

############
## Outputs
############

output "swarm_api_dns_name" {
  value = "${aws_elb.swarm_api.dns_name}"
}
