.PHONY: help mount new_instance install_ansible clean secrets full_test_no_secrets 
.PHONY: full_test fast_test_no_secrets fast_test minimal_test_no_secrets minimal_test test clean_install_ansible


mount:
	-@multipass mount . ltsAnsible:/home/ubuntu/ubuntu_ansible
	
new_instance:
	@multipass launch -n ltsAnsible -c 2 -m 4G -d 15G
	@multipass exec ltsAnsible -- sudo apt update
	@multipass exec ltsAnsible -- sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt upgrade -y
	@multipass restart ltsAnsible
	@sleep 2 # Wait for the instance to restart. It raises sometimes ssh errors otherwise.

install_ansible:
	@multipass exec ltsAnsible -- sudo apt update
	@multipass exec ltsAnsible -- sudo apt install -y software-properties-common
	@multipass exec ltsAnsible -- sudo add-apt-repository --yes --update ppa:ansible/ansible
	@multipass exec ltsAnsible -- sudo apt install -y ansible git

clean:
	- multipass delete ltsAnsible
	multipass purge

secrets:
	@multipass exec ltsAnsible --working-directory /home/ubuntu/ubuntu_ansible -- ansible-playbook --vault-password-file ./secrets/.pass.txt secrets.yml
	@multipass exec ltsAnsible --working-directory /home/ubuntu/ubuntu_ansible -- ansible-playbook main-after-secrets.yml

clean_install_ansible: clean new_instance install_ansible

mount_and_main: mount
	@multipass exec ltsAnsible --working-directory /home/ubuntu/ubuntu_ansible -- ansible-playbook main.yml

full_test_no_secrets: clean_install_ansible mount_and_main
	
full_test: full_test_no_secrets secrets
	@multipass restart ltsAnsible

fast_test_no_secrets: clean_install_ansible mount
	@multipass exec ltsAnsible --working-directory /home/ubuntu/ubuntu_ansible -- ansible-playbook main.yml --tags fast

fast_test: fast_test_no_secrets secrets

minimal_test_no_secrets: clean new_instance install_ansible mount
	@multipass exec ltsAnsible --working-directory /home/ubuntu/ubuntu_ansible -- ansible-playbook main.yml --tags minimal

minimal_test: minimal_test_no_secrets secrets

test: mount
	@multipass exec ltsAnsible --working-directory /home/ubuntu/ubuntu_ansible -- ansible-playbook python.yml