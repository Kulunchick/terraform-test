#!/bin/sh

set -eux

terraform init
terraform apply -auto-approve

sleep 60

export ANSIBLE_CONFIG=ansible.cfg
ansible-playbook -i inventory.yml playbooks/site.yml
