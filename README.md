# pTFE-auto-install


Terraform to install infrastructure:
- VPC
- Network
- Routing
- Security Group
- Instance
- DNS record
- SSH key access
- inventory file for ansible

The public ssh key is already uploaded to AWS within the correct region!

To be fully agile you need to be able to address all this resources within AWS.
My Route53 domain is: mydomain.xyz

You need a proper license.rli file to be placed into ansible/roles/ptfe/files/license.rli 

Ansible to setup and configure pTFE
- common role: prepares the server 
- create_cert role: creates SSL/TLS certificates using letsencrypt
- copy_cert role: copy already existing certificates to the host (optional) 
  (the amount of certificate creation is limited so you can optional backout the create_cert role and use copy_cert instead)
- ptfe role: provides /etc/replicated.conf and application-settings.json to be prepared to install Terraform

The initial password to access the webfrontend can be found in ansible/roles/ptfe/vars/main.yml
