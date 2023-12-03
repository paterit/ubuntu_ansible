# Update new instance of Ubuntu with Ansible

## Set up local (K)Ubuntu with Ansible

Update and upgrade the host then install Ansible and git with reboot at the end.

```bash
sudo apt update && \
sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt upgrade -y && \
sudo add-apt-repository --yes --update ppa:ansible/ansible && \
sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a \
apt install -y ansible git software-properties-common && \
sudo reboot -f
```

Clone this repo and run Ansible playbooks. You will be prompted for your password to run `sudo` tasks.

```bash
git clone https://github.com/paterit/ubuntu_ansible.git && \
cd ubuntu_ansible && \
ansible-playbook -K main.yml
```

Log out and log in again to apply changes.

Then register your SSH keys by copying my encrypted dotfiles as a zipped private repo (`dotfiles-main.zip`) from GitHub, running the `secrets.yml` playbook and inputting a password (eg. stored in the password manager) when prompted.

```bash
ansible-playbook --ask-vault-pass secrets.yml
```

Once you have access to your private repos, you can run the  `main-after-secrets.yml` playbook:

```bash
ansible-playbook main-after-secrets.yml
```

## Testing on multipass

Full cycle:

* delete and purge multipass instance
* launch new instance
* update
* install ansible
* mount this folder
* play `main.yml` playbook
* add secrets
* play `main-after-secrets.yml` playbook

```bash
make full_test
```

Launch some playbook:

```bash
make test
```
