####################
## Generate ../ansible/default/mail.yml
####################

# Generate file
data "template_file" "ansible_vars" {
    template = "${file("${path.module}/template/main.yml")}"
    depends_on = ["aws_instance.bastion"]
    vars {
      bastion_ip = "${aws_instance.bastion.public_ip}"
      private_subnet_cidr = "${var.private_subnet1_cidr}"
      cloudwatch_ui_logs_group_name = "${var.cloudwatch_ui_logs_group_name}"
      aws_region = "${var.region}"
    }
}
resource "null_resource" "ansible_vars" {
  triggers {
    template_rendered = "${ data.template_file.ansible_vars.rendered }"
  }
  provisioner "local-exec" {
    command = "echo '${ data.template_file.ansible_vars.rendered }' > ../ansible/defaults/main.yml"
  }
}
