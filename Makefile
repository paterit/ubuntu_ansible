mount:
	-@multipass mount . ltsAnsible:/home/ubuntu/ubuntu_ansible
	
new_instance:
	@multipass launch -n ltsAnsible -c 2 -m 4G -d 10G
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

full_test: clean new_instance install_ansible mount
	@multipass exec ltsAnsible --working-directory /home/ubuntu/ubuntu_ansible -- ansible-playbook main.yml

test: mount
	@multipass exec ltsAnsible --working-directory /home/ubuntu/ubuntu_ansible -- zsh -ic 'ansible-playbook main.yml'