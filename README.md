# Swarm cluster for AWS
Setup a swarm cluster production ready haven't been so easy !

This is a bootstrap project, which creates 6 swarm nodes, 3 managers and 3 workers.

All Swarm nodes are in a single private subnet and they have access to internet via a Nat Gateway in the public subnet.

There is also a Bastion Host to configure and SSH the swarm nodes.
A default Elastic Load Balancer is created also that listens the trafic on **TCP:3000** of all swarm nodes and load balance TCP trafic comming from the internet on the **port 80**.

**You can find a more detailled view as above:**
![Cloud visual description](https://github.com/markthebault/aws-swarm-cluster-for-production/blob/master/cloud-image.png)

## Boostraping a Swarm cluster in AWS
This project uses CoreOS images on alpha version (to get the last updates from docker)

### 1/ Provisionning of the infrastructure
Make sure you environment contains the following variables:
```
export AWS_ACCESS_KEY_ID=<your access key>
export AWS_SECRET_ACCESS_KEY=<your secrect key>
```

Create a file terraform.tfvars in `./terraform`

**Example:**
```
control_cidr = "10.234.231.21/32"
owner = "Mark"
default_keypair_name = "swarm-clstr-kp"
default_keypair_path = "~/.ssh/swarm-clstr-kp.pem"
```

Execute `terraform plan` to see what will be created and `terraform apply` to start terraforming ;)

#### Quick start
To start even faster just run the make file `make up`, this will create the infrastructure and provisionning the VMs.
To destroy everything just run `make down`.


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

### 4/ Connect with OpenVPN
You can connect to your cluster swarm direclty with openvpn and access to your services that you have deployed on your swarm cluster
First you need to **add openvpn service to bastion**.

OpenVPN is based on this [github](https://github.com/kylemanna/docker-openvpn).

Run the ansible playbook `cd ansible && ansible-playbook bastion.yml`

this will automaticaly create a file in `/tmp/CLIENTADMIN.conf` with the configuration of the OpenVPN.

If it fails, you can run manualy the following scripts `./scripts/get-admin-vpn-cert.sh > myconf.conf`.

To create more configuration for your users you can run the script `./scripts/create-client-vpnconf.sh client-name file-name.conf`

### 5/ Monitoring
**This is experimental monitoring**

The Monitoring stack have been done using [this stack](https://grafana.com/dashboards/609).
To run the Monitoring, execute `cd ./ansible && ansible-playbook docker-monitoring.yml`
You can also find an example of grafana dashboards in `./monitoring/grafana-dashboard/docker-swarm-container-overview.json`
Grafana is accessible on the port `http://SWARM_NODE:3000` (you need to connect with the vpn in order to access to this service).

## Optimisations
- Currently the project works only on one AZ so that's not very good for high availability
- The project only support AWS
