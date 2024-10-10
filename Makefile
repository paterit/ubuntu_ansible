.PHONY: help mount new_instance install_ansible clean secrets full_test_no_secrets 
.PHONY: full_test fast_test_no_secrets fast_test minimal_test_no_secrets minimal_test test clean_install_ansible

instance_name = ltsAnsible

mount:
	-@multipass mount . $(instance_name):/home/ubuntu/ubuntu_ansible
	
new_instance:
	@multipass launch -n $(instance_name) -c 8 -m 8G -d 30G
	@multipass exec $(instance_name) -- sudo apt update
	@multipass exec $(instance_name) -- sudo add-apt-repository --yes --update ppa:ansible/ansible
	@multipass exec $(instance_name) -- sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt upgrade -y
	@multipass exec $(instance_name) -- sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a \
		apt install -y ansible git software-properties-common

	@multipass restart $(instance_name)
	@sleep 2 # Wait for the instance to restart. It raises sometimes ssh errors otherwise.

clean:
	- multipass delete $(instance_name)
	multipass purge

secrets:
	@multipass exec $(instance_name) --working-directory /home/ubuntu/ubuntu_ansible -- cp ./secrets/dotfiles-main.zip /home/ubuntu/
	@multipass exec $(instance_name) --working-directory /home/ubuntu/ubuntu_ansible -- ansible-playbook --vault-password-file ./secrets/.pass.txt secrets.yml
	@multipass exec $(instance_name) --working-directory /home/ubuntu/ubuntu_ansible -- ansible-playbook main-after-secrets.yml

clean_install_ansible: clean new_instance

mount_and_main: mount
	@multipass exec $(instance_name) --working-directory /home/ubuntu/ubuntu_ansible -- ansible-playbook main.yml

full_test_no_secrets: clean_install_ansible mount_and_main
	
full_test: full_test_no_secrets secrets
	@multipass restart $(instance_name)

fast_test_no_secrets: clean_install_ansible mount
	@multipass exec $(instance_name) --working-directory /home/ubuntu/ubuntu_ansible -- ansible-playbook main.yml --tags fast

fast_test: fast_test_no_secrets secrets

minimal_test_no_secrets: clean_install_ansible mount
	@multipass exec $(instance_name) --working-directory /home/ubuntu/ubuntu_ansible -- ansible-playbook main.yml --tags minimal

minimal_test: minimal_test_no_secrets secrets

test: mount
	@multipass exec $(instance_name) --working-directory /home/ubuntu/ubuntu_ansible -- ansible-playbook devbox.yml

mp_restore_devbox:
	@multipass stop $(instance_name)
	@multipass restore --destructive $(instance_name).nix
	@multipass start $(instance_name)
	
mp_test:
	@multipass stop $(instance_name)
	@multipass restore --destructive $(instance_name).test
	@multipass start $(instance_name)
	make test

debug:
	@multipass exec $(instance_name) --working-directory /home/ubuntu/ubuntu_ansible -- ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook -v devbox.yml