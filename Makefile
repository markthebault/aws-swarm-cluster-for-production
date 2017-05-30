up: infrastructure sleep provisionning ui-service


infrastructure:
	cd terraform && terraform apply

sleep:
	sleep 60

provisionning:
	cd ansible && ansible-playbook bootstrap.yml
	cd ansible && ansible-playbook init-swarm.yml
	cd ansible && ansible-playbook bastion.yml

ui-service:
	cd ansible && ansible-playbook docker-ui.yml


down:
	cd terraform && terraform destroy
