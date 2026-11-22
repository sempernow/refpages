# Ansible [Documentation](https://docs.ansible.com/ansible/latest/ "docs.ansible.com") | [Getting Started](https://docs.ansible.com/ansible/latest/getting_started/index.html)

Agentless Push Automation : [`ansible-topology.png`](ansible-topology.png)

```bash
ansible-playbook \
    -i inventory.file \
    -u ssh_user \
    playbook.yml

```

## Summary

Ansible is the property of RedHat, Inc. 

Ansible is a highly versatile tool for remotely provisioning and confuguring declared sets of target machines. It is designed for targets well beyond Linux; network appliances of many vendors. That is its strong point, and explains its lack of sensible defaults for Linux.

Referred to as "agentless" because the app itself has no process running on targets, unlike other provisioning tools. Ansible connects to targets via their SSH server (`sshd`), though its default behavior is to ignore the user's SSH configurations (on the control node). 

Ansible is written in Python, with an ecosystem of modules for a vast range of tasks and target types. Python must also be installed on all targets for all but the most trivial use cases; a version compatible with that of Ansible (installed only on the control node). 

Each target environment and task has its own set of Python modules and its own set of configuration (YAML or INI) requirements. 

Ansible makes no attempt to abide any existing GNU/POSIX/Bash conventions or configurations. So, manhours consumed in declaring IaC of any real-world environment is significant. If all targets are Linux, however, that cost may be significantly lowered by using Ansible only as a bash-script runner; avoiding its labyrinth of per-module syntax and configurations. 

Running ansible in verbose mode (`-vvv`) prints its (attempted) SSH connection statement:

```bash
ssh -C -o ControlMaster=auto -o ControlPersist=60s -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o 'User="u1"' -o ConnectTimeout=10 -o 'ControlPath="/c/HOME/.ansible/cp/975de6127e"' $ip '/bin/sh -c '"'"'hostname'"'"''
```
- This fails on WSL2 due to Ansible's default `ControlMaster` (connection sharing) option to reuse an already-established connection, which requires a socket.

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

## Configuration : [`ansible.cfg`](ansible.cfg) : [Configuration Settings](https://docs.ansible.com/ansible/latest/reference_appendices/config.html "docs.ansible.com")

Format is a particular `INI` variant: 

```ini
# Comment
; Comment
foo = bar ; Comment inline
```

Search order:

- `ANSIBLE_CONFIG` 
- `$(pwd)/ansible.cfg` 
- `~/.ansible.cfg` 
- `/etc/ansible/ansible.cfg`

(None are created upon installation.)

### Create 

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
- [`ansible-config.init-t.all.cfg`](ansible-config.init-t.all.cfg)

### Project Structure

```bash
mkdir -p {inventory/{dev/{group_vars,host_vars},pro/{group_vars,host_vars}},playbooks/roles/{common/{tasks,handlers,templates,files,vars,defaults,meta,library},role-a/{tasks,files},role-b/{tasks,files,templates,vars}}}
touch ansible.cfg inventory/dev/hosts inventory/pro/hosts
```
```plaintext
☩ tree
.
├── inventory
│   ├── dev
│   │   ├── group_vars
│   │   ├── host_vars
│   │   └── hosts
│   └── pro
│       ├── group_vars
│       ├── host_vars
│       └── hosts
├── playbooks
│   └── roles
│       ├── common
│       │   ├── defaults
│       │   ├── files
│       │   ├── handlers
│       │   ├── library
│       │   ├── meta
│       │   ├── tasks
│       │   ├── templates
│       │   └── vars
│       ├── role-a
│       │   ├── files
│       │   └── tasks
│       └── role-b
│           ├── files
│           ├── tasks
│           ├── templates
│           └── vars
└── ansible.cfg

```

@ **`ansible.cfg`** | [Configuration Settings](https://docs.ansible.com/ansible/latest/reference_appendices/config.html "docs.ansible.com")

```ini
[defaults]
inventory = ./inventory/hosts
```

@ **`inventory/hosts`** | [Inventory Guide](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html "docs.ansible.com")

Note it's typically named `hosts`, not `hosts.yml`.

```yaml
all:
  children:
    cluster:
      vars:
        cluster_scope: All hosts of all groups under cluster group
      children:
        master:
          hosts:
            a: a.lan
            b: b.lan
          vars:
            master_scope: All hosts of master group 
        worker:
          hosts:
            c: 192.168.1.10
            d: 
             hostname: d.lan
             port: 5555
    local:
      hosts:
        localhost:
      vars:
        ansible_connection: local
  vars:
    all_scope: All hosts of all groups, local and remote
    ansible_python_interpreter: /usr/bin/env python

```
- Variables may be set here and/or in variables files (YAML) under `host_vars/` and/or `group_vars/`, with each file having name of host or group to which it is scoped.

Target multiple groups and/or hosts with an ad-hoc command:

```bash
ansible master,c -a 'ip -4 addr'
```

@ **`playbooks/site.yml`** (Playbook AKA Playbook file)

```yaml
- hosts: all
  roles:
    - role: myrole  # This will run `roles/myrole/tasks/main.yml`

```

@ **`roles/`** (Roles folder)

```plaintext
roles/
├── myrole/
│   ├── tasks/
│   │   └── main.yml
│   ├── files/
│   │   └── example_file.txt
│   ├── templates/
│   │   └── example_template.j2
│   └── vars/
│       └── main.yml
playbooks/
└── site.yml
```


@ **`myrole/tasks/main.yml`** (Task file)

```yaml
- name: Copy file from role's files directory
  copy:
    src: example_file.txt   # This references roles/myrole/files/example_file.txt
    dest: /destination/path/on/remote

- name: Deploy configuration file from template
  template:
    src: example_template.j2   # This references roles/myrole/templates/example_template.j2
    dest: /etc/config.conf

```

### Common [Connection variables](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html#connection-variables)

Connection variables are normally used to set the specifics on how to execute actions on a target. Some are (required) per module. Here are common ones:


- `ansible_become_user`  
  The user Ansible ‘becomes’ after using privilege escalation. This must be available to the ‘login user’.

- `ansible_connection`  
  The connection plugin actually used for the task on the target host.

- `ansible_host`  
  The ip/name of the target host to use instead of inventory_hostname.

- `ansible_python_interpreter`  
  The path to the Python executable Ansible should use _on the target host_.

- `ansible_user`  
  The user Ansible ‘logs in’ as.


### [Magic variables](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html#magic-variables)

Ansible-controlled; overrides any set by user.


##  [`inventory.yml`](./inventory.yml) | [Ansible Inventories](https://docs.ansible.com/ansible/latest/inventory_guide/index.html  "docs.ansible.com")

Ansible inventories are set(s) of target hosts upon which `ansible` operates. 
These are declared. Default is `inventory.cfg` file.

Format is YAML or proprietary "Ansible Inventory Format". 
Regardless, all must abide Ansible-specified (sub)keys.

Location of this file is declared in Ansible configuration 
(e.g., [`ansible.cfg`](ansible.cfg)) at "`inventory`" key.

```ini
[defaults]
inventory=inventory.cfg
```

@ [**`inventory.yml`**](inventory.yml)

Default inventory file: `/etc/ansible/hosts` 

Validate the inventory file

```bash

ansible-inventory -i inventory/hosts.yml --list --yaml
ansible-inventory -i inventory/hosts.yml --graph

# YAML linter
yamllint inventory/hosts.yml # dnf install yamllint
```



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
    - [`create_provisioner.sh`](create_provisioner.sh)  

@ `~/.ansible.cfg` | [`ansible.cfg`](ansible.cfg)

```ini
[defaults]
action_warnings=False
inventory=inventory.cfg
deprecation_warnings=False
remote_user  = u2
;; become : This setting (True) works only for playbooks. 
;; Whereas ad-hoc commands (-a COMMAND) REQUIRE flag --become regardless.
become = True
become_user = root
[privilege_escalation]
become_method = sudo
become_ask_pass = True
[ssh_connection]
ssh_config = ${HOME}/.ssh/config
;; TTY allocation may cause failure by infinite silent hang 
;; depending on sudoers files configuration. 
;; Sudoers config may require : "Defaults !requiretty"
;ssh_args = -tt
usetty = True
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
scp_if_ssh = smart
;; Force scp
;ssh_transfer_method = scp
timeout = 10
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
ansible $target -a 'ls -hl /etc/sudoers.d/' --become
# shell module
ansible $target -m ansible.builtin.shell -a hostname
# script module
ansible $target -m ansible.builtin.script -a foo.sh 

# playbook : script w/ args injected
ansible-playbook foo.yml -e a=foo -e b=bar 

```

### Privilege Escalation : `sudo` 

```bash
# Ad-hoc sudo commands REQUIRE flag "--become" REGARDLESS of its mirror setting at .cfg 
ansible target -a 'cat /etc/sudoers.d/gitops' --become #=> "BECOME password: "
```

### `ansible-vault`

```bash
# Create vault and add become_password
vault=become_pass.yml
ansible-vault create $vault
    # Prompts for vault password,
    # then opens in editor (vi). Add:
    # ---
    # ansible_become_password:·"PASSWORD"

# View content
ansible-vault view $vault
# Edit content
ansible-vault edit $vault --ask-vault-pass

# Use : 
# 1. Mod ansible.cfg
# - vault_password_file = become_pass.yml
# - become_ask_pass = False
# 2. Playbook
ansible-playbook playbook.yml --extra-vars "@$vault" --ask-vault-pass
# Or Ad-hoc
ansible target -a 'ls -hl /etc/sudoers.d/' --become --extra-vars "@$vault" --ask-vault-pass

```

## Playbook (YAML)

@ `example.yml`

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
and playbook (`example.yml`) set target (group) name (`hosts: local`), 
the command to run the playbook is simply:

```bash
☩ ansible-playbook example.yml

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


@ `foo.yml`

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

