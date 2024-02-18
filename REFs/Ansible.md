# Ansible [Documentation](https://docs.ansible.com/ansible/latest/ "docs.ansible.com")

Agentless Push Automation per SSH 

![ansible-topology.png](ansible-topology.png)


```bash
ansible-playbook \
    -i inventory.file \
    -u ssh_user \
    -e script_path=~/scripts/install_docker.sh \
    playbook.yaml

```

## Summary

In effect, Ansible is an ssh-centric bash wrapper, making the targets' SSH server its agent. Ansible is written in Python, so it runs about a thousand times slower than equivalent GNU/Bash utilities, yet has its own universe of lingo, syntax and quirks. Ansible is owned by RedHat, Inc. 

Ansible ignores the user's SSH configurations, `~/.ssh/config`, to enforce its own. Its default behavior is to establish a socket for connection reuse. Expect connection debugging per enviornment and target set, even after solving that for SSH per se. Ansible hardwires at least some of those connection settings (`ControlMaster`, `ControlPath`), and does not support override entries in `ansible.cfg`. 

Running ansible in verbose mode (`-vvv`) prints the attempted SSH connection statement:

```bash
ssh -C -o ControlMaster=auto -o ControlPersist=60s -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o 'User="u1"' -o ConnectTimeout=10 -o 'ControlPath="/c/HOME/.ansible/cp/975de6127e"' 192.168.0.80 '/bin/sh -c '"'"'echo ~u1 && sleep 0'"'"''
```
- That fails on WSL2, for example.

Each target environment and task has its own set of Ansible (Python) modules, and they make no attempt to abide any existing GNU/POSIX/Bash conventions or configurations. Discovering and learning to use and configure each Ansible module adds significant time/resource costs. Ansible's popularity suggests it either offers significant benefits beyond bash scripting, or the project is well marketed. 

### Install package

```bash
ansible all --user u1 --become \
    --module-name dnf -a’name=docker state=latest’
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

## Prep target(s)

Whether Ansible or vanilla Bash, 
the target host(s) to be provisioned 
must first be prepared manually. 
The script user (`u1`) must have ability to execute
commands with elevated privileges sans password entry:

Here's how to configure:

@ Control machine

```bash
ssh $vm
```

@ Target machine

```bash
sudo vim /etc/sudoers.d/u1
```
```text
u1 ALL=(ALL) NOPASSWD:ALL
```

Or, programmatically

```bash
echo "$USER ALL=(ALL) NOPASSWD:ALL" |sudo tee /etc/sudoers.d/$USER
```

## [Getting Started](https://docs.ansible.com/ansible/latest/getting_started/index.html)

For context, this is the Bash way:

```bash
# Okay
ssh u1@192.168.0.78 
# Okay
ping 192.168.0.78
```

And this is the Ansible way:

@ `/etc/ansible/hosts`

```ini
[machines]
  a1
  192.168.0.80
```

@ WSL2 

```bash

☩ ansible all --list-hosts
  hosts (2):
    a1
    192.168.0.80

☩ ansible all -u u1 -m ping      

a1 | UNREACHABLE! => {    
    "changed": false,   
    "msg": "Failed to connect to the host via ssh: Control socket connect(/c/HOME/.ansible/cp/b4539065e0): Connection refused\r\nFailed to connect to new control master",     
    "unreachable": true   
}     
192.168.0.80 | UNREACHABLE! => {  
    "changed": false,       
    "msg": "Failed to connect to the host via ssh: u1@192.168.0.80: Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).", 
    "unreachable": true 
}     
```
- And is very, very slow (Python) relative to equivalent GNU utils


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

