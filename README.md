# ubuntu_ansible

Set up local (K)Ubuntu with Ansible.

Before installing ansible, update and upgrade with reboot.

```bash
sudo apt update && sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt upgrade -y && sudo reboot -f
```

```bash
sudo apt update && \
sudo apt install -y software-properties-common && \
sudo add-apt-repository --yes --update ppa:ansible/ansible && \
sudo apt install -y ansible git && \
git clone https://github.com/paterit/ubuntu_ansible.git && \
cd ubuntu_ansible && \
ansible-playbook main.yml
```
