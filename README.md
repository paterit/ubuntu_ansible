# Provision a new machine with Ansible

One `main.yml` provisions a fresh **Ubuntu** (desktop or server) **or macOS**
(Apple Silicon) machine. The OS is detected automatically from gathered facts
(`ansible_system`), and platform-specific plays branch or are skipped accordingly:

- **Linux-only** (skipped on macOS): gnome/dconf config, desktop apt/snap/PPA
  apps, Nix + Devbox, and the openssh-server setup.
- **macOS** installs GUI apps (Chrome, Cursor, Docker, VS Code, Spotify, …) via
  Homebrew **casks**; CLI tooling comes from Homebrew formulae and cargo.

Package lists and identity live in `group_vars/all.yml` — edit there, not in the
individual playbooks. Required Galaxy collections are pinned in `requirements.yml`.

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

Clone this repo, install the required collections, and run the playbooks. You
will be prompted for your password to run `sudo` tasks.

```bash
git clone https://github.com/paterit/ubuntu_ansible.git && \
cd ubuntu_ansible && \
ansible-galaxy collection install -r requirements.yml && \
ansible-playbook -K main.yml
```

To install only server packages (no desktop environment), run:

```bash
ansible-playbook -K main.yml --tags server
```

Log out and log in again to apply all the changes. Go to the `~/ubuntu_ansible` folder.

## Set up macOS

On a fresh mac, install the Xcode Command Line Tools and Homebrew (which also
gives you `git`), then Ansible:

```bash
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install ansible
```

Then clone and run the same playbook — Linux-only plays are skipped automatically:

```bash
git clone https://github.com/paterit/ubuntu_ansible.git && \
cd ubuntu_ansible && \
ansible-galaxy collection install -r requirements.yml && \
ansible-playbook -K main.yml
```

> macOS notes: `sudo` (`-K`) is only needed for the few elevated tasks. The
> `cron.yml` job works under macOS `cron` but may require granting your terminal
> "Full Disk Access" in System Settings → Privacy & Security.

## Secrets and private repos

Then register your SSH keys by copying encrypted (with ansible-vault) dotfiles as
a zipped private repo (`dotfiles-main.zip`) from GitHub to your `$HOME` dir,
running the `secrets.yml` playbook, and inputting a password (e.g., stored in the
password manager) when prompted.

```bash
ansible-playbook --ask-vault-pass secrets.yml
```

Once you have access to your private repos, you can run the `main-after-secrets.yml`
playbook. You will be prompted for your password to run `sudo` tasks:

```bash
ansible-playbook -K main-after-secrets.yml
```

## Development: syntax-check and lint

Set up a local virtualenv (uv) with Ansible + ansible-lint and the collections,
then validate the playbooks without touching the machine:

```bash
make setup          # uv venv + ansible, ansible-lint, collections
make syntax_check   # ansible-playbook --syntax-check on the entry playbooks
make lint           # ansible-lint
```

## Testing on multipass (Linux)

Full cycle:

- delete and purge multipass instance
- launch new instance
- update
- install ansible
- mount this folder
- play `main.yml` playbook
- add secrets
- play `main-after-secrets.yml` playbook

```bash
make full_test
```

Launch some playbook:

```bash
make test
```
