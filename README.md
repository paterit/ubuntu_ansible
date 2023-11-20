# Update new instance of Ubuntu with Ansible

## Set up local (K)Ubuntu with Ansible

Before installing Ansible, update and upgrade with reboot.

```bash
sudo apt update && \
sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt upgrade -y && \
sudo reboot -f
```

Install Ansible, clone this repo and run Ansible playbooks.

```bash
sudo apt update && \
sudo apt install -y software-properties-common && \
sudo add-apt-repository --yes --update ppa:ansible/ansible && \
sudo apt install -y ansible git && \
git clone https://github.com/paterit/ubuntu_ansible.git && \
cd ubuntu_ansible && \
ansible-playbook main.yml
```

Then copy encrypted dot files to the `secrets` folder and run

```bash
ansible-playbook --ask-vault-pass secrets.yml
```

## Testing on multipass

Full cycle:

* delete and purge multipass instance
* launch new instance
* update
* install ansible
* mount this folder
* play `main.yml` playbook

```bash
make full_test
```

Launch some playbook:

```bash
make test
```
