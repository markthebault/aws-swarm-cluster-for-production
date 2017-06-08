#########################
## Generate certificates
#########################

# Generate Certificates

data "template_file" "certificates" {
    template = "${file("${path.module}/template/swarm-csr.json")}"
    depends_on = ["aws_instance.master","aws_instance.worker",]
    vars {

      worker0-ip = "${aws_instance.worker.0.private_ip}"
      worker1-ip ="${aws_instance.worker.1.private_ip}"
      worker2-ip ="${aws_instance.worker.2.private_ip}"

      master0-ip ="${aws_instance.master.0.private_ip}"
      master1-ip ="${aws_instance.master.1.private_ip}"
      master2-ip ="${aws_instance.master.2.private_ip}"

      worker0-dns ="${aws_instance.worker.0.private_dns}"
      worker1-dns ="${aws_instance.worker.1.private_dns}"
      worker2-dns ="${aws_instance.worker.2.private_dns}"

      master0-dns ="${aws_instance.master.0.private_dns}"
      master1-dns ="${aws_instance.master.1.private_dns}"
      master2-dns ="${aws_instance.master.2.private_dns}"
    }
}

resource "null_resource" "certificates" {
  triggers {
    template_rendered = "${ data.template_file.certificates.rendered }"
  }

  provisioner "local-exec" {
    command = "echo '${ data.template_file.certificates.rendered }' > ../certificates/swarm-csr.json"
  }
}
