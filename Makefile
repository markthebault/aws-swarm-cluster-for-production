BASEDIR=$(shell pwd)
TERRAFORM_VARS ?= ${BASEDIR}/terraform.tfvars
TERRAFORM_STATE ?= ${BASEDIR}/terraform.tfstate
TERRAFORM_STATE_BACKUP ?= ${BASEDIR}/terraform.tfstate.backup

up: infrastructure sleep provisionning ui-service

plan:
	cd terraform && terraform plan -var-file=${TERRAFORM_VARS} -state=${TERRAFORM_STATE}

infrastructure:
	cd terraform && \
		terraform apply -var-file=${TERRAFORM_VARS} \
			-state=${TERRAFORM_STATE} \
			-backup=${TERRAFORM_STATE_BACKUP}

sleep:
	sleep 60

provisionning:
	cd ansible && ansible-playbook bootstrap.yml
	cd ansible && ansible-playbook init-swarm.yml
	cd ansible && ansible-playbook bastion.yml

ui-service:
	cd ansible && ansible-playbook docker-ui.yml


down:
	cd terraform && \
		terraform destroy -var-file=${TERRAFORM_VARS} \
			-state=${TERRAFORM_STATE} \
			-backup=${TERRAFORM_STATE_BACKUP}
