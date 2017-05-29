variable control_cidr {
  description = "CIDR for maintenance: inbound traffic will be allowed from this IPs"
}

variable default_keypair_name {
  description = "Name of the KeyPair used for all nodes"
  default = "swarm-keypair"
}

variable default_keypair_path {
  description = "Private Key to insert in all nodes"
}





variable vpc_name {
  description = "Name of the VPC"
  default = "swarm"
}

variable elb_name {
  description = "Name of the ELB for swarm API"
  default = "swarm-elb"
}

variable owner {
  default = "swarm"
}

variable ansibleFilter {
  description = "`ansibleFilter` tag value added to all instances, to enable instance filtering in Ansible dynamic inventory"
  default = "swarm01" # IF YOU CHANGE THIS YOU HAVE TO CHANGE instance_filters = tag:ansibleFilter=swarm01 in ./ansible/hosts/ec2.ini
}

# Networking setup
variable region {
  default = "eu-west-1"
}

variable zone {
  default = "eu-west-1a"
}

### VARIABLES BELOW MUST NOT BE CHANGED ###

variable vpc_cidr {
  default = "10.43.0.0/16"
}

variable public_subnet1_cidr {
  default = "10.43.0.0/24"
}

variable private_subnet1_cidr {
  default = "10.43.1.0/24"
}



# Instances Setup
variable amis_swarm {
  description = "Default AMIs to use for nodes depending on the region"
  type = "map"
  default = {
    eu-west-1 = "ami-0c3a346a"
  }
}

variable ami_bastion {
  description = "Default AMI for Bastion"
  type = "map"
  default = {
    eu-west-1 = "ami-0c3a346a"
  }
}



variable default_instance_user {
  default = "core"
}
variable master_instance_type {
  default = "t2.micro"
}
variable worker_instance_type {
  default = "t2.micro"
}

variable bastion_instance_type {
  default = "t2.micro"
}

variable nb_swarm_master{
  description = "Choose the number of swarm master that you want, this have to be an odd number 1,3,5,7"
  default = 3
}

variable nb_swarm_workers{
  description = "Choose the number of swarm workers that you want"
  default = 3
}


variable swarm_cluster_dns {
  default = "10.31.0.1"
}
