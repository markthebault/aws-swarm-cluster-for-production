BASEDIR=$(shell pwd)
TERRAFORM_VARS ?= ${BASEDIR}/terraform.tfvars
TERRAFORM_STATE ?= ${BASEDIR}/terraform.tfstate
TERRAFORM_STATE_BACKUP ?= ${BASEDIR}/terraform.tfstate.backup

help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

up: ## Build the infra in one step
up: infrastructure sleep provisionning ui-service

plan: ## Show what will be done on the infrastructure
plan:
	cd terraform && terraform plan -var-file=${TERRAFORM_VARS} -state=${TERRAFORM_STATE}


infrastructure: ## Build the infrastructure
infrastructure:
	cd terraform && \
		terraform apply -var-file=${TERRAFORM_VARS} \
			-state=${TERRAFORM_STATE} \
			-backup=${TERRAFORM_STATE_BACKUP}

sleep:
	sleep 60

provisionning: ## Provisionning of the VMs, make sure there are ready
provisionning:
	cd ansible && ansible-playbook bootstrap.yml
	cd ansible && ansible-playbook init-swarm.yml
	cd ansible && ansible-playbook bastion.yml

ui-service: ## Deploy portainer container on the swamr
ui-service:
	cd ansible && ansible-playbook docker-ui.yml


down: ## !!! This step will destroy all
down:
	cd terraform && \
		terraform destroy -var-file=${TERRAFORM_VARS} \
			-state=${TERRAFORM_STATE} \
			-backup=${TERRAFORM_STATE_BACKUP}
