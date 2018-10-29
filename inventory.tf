## dynamically generate a `inventory` file for Ansible Configuration Automation 

data "template_file" "ansible_masternode" {
    count      = "${var.tfe_node_count}"
    template   = "${file("${path.module}/templates/ansible_hosts.tpl")}"
    depends_on = ["aws_instance.tfe_node"]

      vars {
        node_name    = "${lookup(aws_instance.tfe_node.*.tags[count.index], "Name")}"
        ansible_user = "${var.ssh_user}"
        extra        = "ansible_host=${element(aws_instance.tfe_node.*.public_ip,count.index)}"
##        extra        = "ansible_host=${element(hcloud_server.masternode.*.ipv4_address,count.index)}"
      }

}


data "template_file" "ansible_groups" {
    template = "${file("${path.module}/templates/ansible_groups.tpl")}"

      vars {
        ssh_user_name = "${var.ssh_user}"
        masternode_def  = "${join("",data.template_file.ansible_masternode.*.rendered)}"
      }

}

resource "local_file" "ansible_inventory" {
    content = "${data.template_file.ansible_groups.rendered}"
    filename = "${path.module}/ansible/inventory"

}

