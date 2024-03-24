# Ansible [Documentation](https://docs.ansible.com/ansible/latest/ "docs.ansible.com") | [Getting Started](https://docs.ansible.com/ansible/latest/getting_started/index.html)

Agentless Push Automation

![ansible-topology.png](ansible-topology.png)


```bash
ansible-playbook \
    -i inventory.file \
    -u ssh_user \
    playbook.yaml

```

## Summary

Ansible is a highly versatile tool for provisioning and confuguring user-declared sets of target machines. Though referred to as "agentless", Ansible uses the SSH server running on its target as the agent. It's default behavior, however, is to ignore the user's SSH configurations. Ansible is written in Python, with an ecosystem of modules for a vast range of tasks and target types. Ansible is the property of RedHat, Inc. 

Each target environment and task has its own set of (Python) modules and its own set of configuration (YAML) requirements (k-v pairs). Ansible makes no attempt to abide any existing GNU/POSIX/Bash conventions or configurations. Discovering and learning to use and configure the array of Ansible modules required to perform even the typical provision/configure tasks upon a set of Linux VMs consumes a significant amount of manhours. Ansible's popularity suggests it either offers significant benefits beyond bash scripting, or the project is well marketed. 

Running ansible in verbose mode (`-vvv`) prints its (attempted) SSH connection statement:

```bash
ssh -C -o ControlMaster=auto -o ControlPersist=60s -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o 'User="u1"' -o ConnectTimeout=10 -o 'ControlPath="/c/HOME/.ansible/cp/975de6127e"' 192.168.0.80 '/bin/sh -c '"'"'echo ~u1 && sleep 0'"'"''
```
- That fails on WSL2, for example.

## Install 

```bash
# Install Python 3
sudo dnf -y install python3
# Set Python 3 as default
alternatives --set python /usr/bin/python3
# Install Python pip
sudo dnf -y install python3-pip
# Install ansible for current user (@ ~/.local or %APPDATA%Python)
python3 -m pip install --user ansible 
# Or 
python3 -m pip install --include-deps --user ansible
# Or just the core
python3 -m pip install ansible-core

# Upgrade
python3 -m pip install --upgrade --user ansible

# Add Autocomplete
python -m pip install --user argcomplete 

# Verify
ansible --version
```
- [`pip install`](https://pip.pypa.io/en/stable/cli/pip_install/ "pip.pypa.io")

## [Configuration Settings](https://docs.ansible.com/ansible/latest/reference_appendices/config.html) | [`ansible.cfg`](ansible.cfg)

Search order:

- `ANSIBLE_CONFIG` 
- `$(pwd)/ansible.cfg` 
- `~/.ansible.cfg` 
- `/etc/ansible/ansible.cfg`

(None are created upon installation.)

### Create a local configuration 

The `ansible-config` command provides all the configuration settings available, 
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

### Inventory | [`inventory.cfg`](inventory.cfg)

The set(s) of target hosts upon which `ansible` operates.

Set location of `inventory.cfg` at `inventory` key of [`ansible.cfg`](ansible.cfg).

```ini
[defaults]
inventory=inventory.cfg
```

Default inventory file: `/etc/ansible/hosts` 

## Prep target(s)

There are several conventions for configuring target machines.
A simple, secure method is to configure the script user (`gitops`) 
on the target(s) such that their password login is entirely disabled, 
making remote, key-based ssh login the only method of access,
and then creating a `/etc/sudoers.d/gitops` file that enables 
elevated privileges sans password entry.

- Install Ansible on admin node (not a cluster node)
- Prepare all target machines by running this script on each one. 
  It requires `root` privileges.
    - [`create_provisioner_target_node.sh`](create_provisioner_target_node.sh)  
      Manually at a target machine:
        ```bash
        sudo vim /etc/sudoers.d/u1
        ```
        ```text
        u1 ALL=(ALL) NOPASSWD:ALL
        ```
        Alternately: 
        ```bash
        echo "$USER ALL=(ALL) NOPASSWD:ALL" |sudo tee /etc/sudoers.d/$USER
        ```


@ `~/.ansible.cfg`

```ini
[defaults]
action_warnings=False
inventory=inventory.cfg
deprecation_warnings=False
remote_user=gitops
[privilege_escalation]
become_user=root
[persistent_connection]
[connection]
[colors]
[selinux]
[diff]
[galaxy]
[inventory]
[netconf_connection]
ssh_config=${HOME}/.ssh/config
[paramiko_connection]
[jinja2]
[tags]

```

## Use 

```bash
# Ad-hoc command at one machine of default hosts file @ /etc/ansible/hosts
ansible -i hosts 192.168.1.109 -m ping
# Ad-hoc command (model: ping) at all target machines of hosts file @ /etc/ansible/hosts
ansible -i hosts app -m ping
# Same as above, but target is self
ansible -m ping localhost 
# Lists all facts of target (using model: setup)
ansible -m setup localhost

# Create ./ansible.cfg that includes declared inventory file.
ansible-config init --disabled |tee ansible.cfg.disabled
vim ansible.cfg.disabled # Edit; declare "inventory=inventory.cfg", and save as ansible.cfg
vim inventory.cfg # add [target] list of hosts
target='target'

# Ad-hoc command ping at $target machines declared in inventory file declared in ./ansible.cfg
ansible $target -m ping
# Ad-hoc : two commands
ansible $target -a hostname -a id
# Ad-hoc : Test is Ansible's ssh user (defaults to current user) has sudo sans password
ansible $target -a 'sudo ls -hl /etc/sudoers.d/'
# shell module
ansible $target -m ansible.builtin.shell -a hostname
# script module
ansible $target -m ansible.builtin.script -a foo.sh 

# playbook : script w/ args injected
ansible-playbook foo.yaml -e a=foo -e b=bar 

```

## Playbook (YAML)

@ `example.yaml`

```yaml
---
- name: example playbook
  hosts: local
  vars:
    foo: "bar"
    fbool: false
    cities:
    - Maryland
    - Virginia
  tasks:
  - name: print foo
    ## model: debug
    ansible.builtin.debug:
      msg: "value of foo is: {{ foo }}"
    ## Run task only on fbool: true
    when: fbool
  - name: print cities
    ## model: debug
    ansible.builtin.debug:
      #var: item 
    loop: "{{ cities }}"

```

Because `ansible.cfg` set the inventory-file path `inventory.cfg` (@ PWD), 
and playbook (`example.yaml`) set target (group) name (`hosts: local`), 
the command to run the playbook is simply:

```bash
☩ ansible-playbook example.yaml

PLAY [example playbook] ***...


TASK [Gathering Facts] ***...
ok: [localhost]

TASK [print foo] ***...
skipping: [localhost]

TASK [print cities] ***...
ok: [localhost] => (item=Maryland) => {
    "msg": "Hello world!"
}
ok: [localhost] => (item=Virginia) => {
    "msg": "Hello world!"
}

PLAY RECAP ***...
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```


@ `foo.yaml`

```yaml
---
- name: Testing
  hosts: target
  vars:
    config_file_path: ~/.ansible/ansible.cfg
  become: true
  #become_flags: "-H -S -n"
  gather_facts: false
  tasks:
  - name: Task 1
    #command: "sh $HOME/devops/ansible/foo.sh {{a}} {{b}}"
    command: "sh $HOME/devops/ansible/foo.sh"

```
- Failing @ WSL(2); all attempts at tweaking ansible's bazillion parameters across its many configuration files (`ansible.cfg`, `inventory.cfg`, playbook, ...) yields same result: hosts not found; can't resolve. 
- Every tool except `ansible` is able to connect to any and every host. 

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

