# pTFE-auto-install

This repo creates a private Terraform Enterprise setup on AWS. 
It is just for my own convenience but might help you as well.

It uses Terraform (OSS) to create the necessary resources (on AWS).
It uses Ansible for OS level configuration.

Prerequisites:
- a license file for TFE
- your public ssh key is already uploaded to AWS within the right region
- DNS domain under control of "Route53"

Terraform creates the following resources:
- VPC
- Network
- Routing
- Security Group
- Instance
- DNS record
- SSH key access
- inventory file for ansible

make your changes in variables.tf and terraform.tfvars

Ansible to setup and configure pTFE
- common role: prepares the server 
- create_cert role: creates SSL/TLS certificates using letsencrypt
- copy_cert role: copy already existing certificates to the host (optional) 
  (the amount of certificate creation is limited so you can optional backout the create_cert role and use copy_cert instead)
- ptfe role: provides /etc/replicated.conf and application-settings.json to be prepared to install Terraform

The initial password to access the webfrontend can be found in ansible/roles/ptfe/vars/main.yml
Copy your license file into ansible/roles/ptfe/files (and ensure this file will be copied to the instance)
Change the email address in ansible/role/create_cert/vars/main.yaml

The final step after terraform apply:
cd ansible
ansible-playbook -i inventory playbook.yml

Good luck ;-)

PS:  $ replicatedctl app-config export > settings.json 
