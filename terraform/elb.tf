###############################
## swarm API Load Balancer
###############################

resource "aws_elb" "swarm_elb" {
    name = "${var.elb_name}"
    instances = ["${aws_instance.master.*.id}","${aws_instance.worker.*.id}"]
    subnets = ["${aws_subnet.swarm_public.id}"]
    cross_zone_load_balancing = false

    security_groups = ["${aws_security_group.swarm_elb.id}"]

    #Simple UI Docker
    listener {
      lb_port = 80
      instance_port = 3000
      lb_protocol = "TCP"
      instance_protocol = "TCP"
    }

    health_check {
      healthy_threshold = 2
      unhealthy_threshold = 2
      timeout = 15
      target = "HTTP:3000/"
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

resource "aws_security_group" "swarm_elb" {
  vpc_id = "${aws_vpc.swarm.id}"
  name = "swarm-elb-sg"

  #Simple UI Docker
  ingress {
    from_port = 80
    to_port = 80
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
    Name = "swarm-elb-sg"
  }
}

############
## Outputs
############

output "swarm_api_dns_name" {
  value = "${aws_elb.swarm_elb.dns_name}"
}
