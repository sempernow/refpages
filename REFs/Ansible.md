# Ansible [Documentation](https://docs.ansible.com/ansible/latest/ "docs.ansible.com")

Agentless Push Automation per SSH

[ansible_topology.svg](ansible_topology.svg)

## TL;DR

This is nothing but a bash wrapper that is ssh centric. Yet it has an entire universe of new syntaxes, and requires special python modules per task.

In effect, our bash provisioning scripts that call the ssh-wrapper function, injecting commands or scripts per positional parameters, does the same thing, will zero added mental load beyond bash.

Perhaps use to run bash scripts per `playbook.yaml`:

```yaml
- name: Script runner
  hosts: all
  tasks:
     - name: Install Docker  
       script: {{ script_path }}
```

```bash
ansible-playbook \
    -i inventory.file \
    -u ssh_user \
    -e script_path=~/scripts/install_docker.sh \
    playbook.yaml

```

Bash is simpler, requires no prep, and is as automated:

```bash
 ssh h1 /bin/bash -s < install_docker.sh
```

Either way, target host must be prepared. 
Script user (`x1`) must have sudo privileges sans password entry:

```bash
sudo vim /etc/sudoers.d/x1
```
```text
x1 ALL=(ALL) NOPASSWD:ALL
```

## Install (@ Python 3.10)

```bash
pipx install --include-deps ansible
pipx inject ansible argcomplete

# Alt method:
python -m pip install ansible
python -m pip install --user argcomplete 
```

Verify (@ WSL)

```bash
ansible --version
```
```text
ansible [core 2.15.2]
  config file = None
  configured module search path = ['/c/HOME/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /c/HOME/.local/pipx/venvs/ansible/lib/python3.10/site-packages/ansible
  ansible collection location = /c/HOME/.ansible/collections:/usr/share/ansible/collections
  executable location = /c/HOME/.local/bin/ansible
  python version = 3.10.12 (main, Jun 11 2023, 05:26:28) [GCC 11.4.0] (/c/HOME/.local/pipx/venvs/ansible/bin/python)
  jinja version = 3.1.2
  libyaml = True
```

## Ad-hoc Commands

Install a package onto a target machine.

### Prep target

Target must contain file allowing ansible user (`x1`) sudo privileges.
Here's how to configure:

```bash
ssh h1
```
```bash
sudo vim /etc/sudoers.d/x1
```
```text
x1 ALL=(ALL) NOPASSWD:ALL
```

### Install package

```bash
ansible all --user x1 --become \
    --module-name dnf -a’name=docker state=latest’
```

## [Configuration Settings](https://docs.ansible.com/ansible/latest/reference_appendices/config.html) | [`ansible.cfg`](ansible.cfg)


NONE EXIST lest you manually create them.

Search order:

- `ANSIBLE_CONFIG` 
- `$(pwd)/ansible.cfg` 
- `~/.ansible.cfg` 
- `/etc/ansible/ansible.cfg`

### Create a local configuration 

>`ansible-config` provides all the configuration settings available, 
  their defaults, how to set them and where their current value comes from.

```bash
# Defaults
ansible-config init > ansible.cfg
# Zero config : everything commented out
ansible-config init --disabled > ansible.cfg
# Include those of all "existing" plugins
ansible-config init -t all > ansible.cfg
```
- [`ansible-config init`](ansible-config.init.cfg)
- [`ansible-config init -t all`](ansible-config.init-t.all.cfg)

### Inventory

The set(s) of target hosts upon which `ansible` operates.

Set location to `$(pwd)/hosts` @ `ansible.cfg` : `inventory=hosts`

### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (HTML | MD)

([HTML](___.md "___"))   


# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->

