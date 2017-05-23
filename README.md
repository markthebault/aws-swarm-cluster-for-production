# Swarm cluster for AWS
Setup a swarm cluster production ready haven't been so easy !

![Cloud visual description](https://github.com/markthebault/aws-swarm-cluster-for-production/blob/master/cloud-image.png)

## Boostraping a Swarm cluster in AWS
This project uses CoreOS images on alpha version (to get the last updates from docker)

### 1/ Provisionning of the infrastructure
Create a file terraform.tfvars in `./terraform`

**Example:**
```
control_cidr = "10.234.231.21/32"
owner = "Mark"
default_keypair_name = "swarm-clstr-kp"
default_keypair_path = "~/.ssh/swarm-clstr-kp.pem"
```

Execute `terraform plan` to see what will be created and `terraform apply` to start terraforming ;)

### 2/ Init the Swarm cluster
All operations are executed by ansible so make sure that you have you private-key in your ssh agent
`ssh-add -K ~/.ssh/swarm-clstr-kp.pem` (on macOS)

Install ansible requirement on CoreOS (go in the ansible folder `./ansible`):
`ansible-playbook bootstrap.yml`

Start the cluster:
`ansible-playbook init-swarm.yml`

Start if you want [portainer](http://portainer.io/) (a web ui for docker)
`ansible-playbook docker-ui.yml`

### 3/ Run new services
To start a new services is very easy, you can follow [docker's tutorials](https://docs.docker.com/engine/reference/commandline/service_create/)

Be aware of the loadbalancer is only configured to load balance trafic incoming from TCP:80 to go on TCP:3000 of the swarm instances

To change the load balancer configuration you can change the following file: `./terraform/elb.tf` don't forget to change the attached security group


## Optimisations
- Currently the project works only on one AZ so that's not very good for high availability
- The project only support AWS
