# [Python.org](https://www.python.org/) | [PyPI](https://pypi.org/) | [`hub.docker.com`](https://hub.docker.com/_/python/tags?page=1&name=3.7.15) | [`docs.python.org`](https://docs.python.org/release/3.7.15/)

## Install 

Examples for Python 3.7

### From [Source Releases](https://www.python.org/downloads/source/)

```bash
ver='3.7.15'
wget https://www.python.org/ftp/python/${ver}/Python-${ver}.tar.xz
tar xvf Python-${ver}.tar.xz
pushd "Python-${ver}"
./configure --help # For options
./configure --enable-optimizations
make 
make test
sudo make install
```

### Using package manager

```bash
# RHEL/CentOS/AlmaLinux/Fedora
sudo dnf install python37 -y
# Debian/Ubuntu
sudo apt-get install python37 -y
```

### RHEL 8+

WARNING : Some RHEL tools, e.g., `sealert`, require the OS-default version of Python.

```bash
# @ Python 3.12.x
dnf provides python312 
sudo dnf -y install python312
sudo dnf -y install python3.12-pip 

# Register Python 3.9 with priority 1
sudo alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1

# Register Python 3.12 with priority 2 (higher priority)
sudo alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 2

# List versions and order (non-interactive)
sudo alternatives --disply python3
# List/Select default version (interactive)
sudo alternatives --config python3

# Verify 
python --version # Python 3.12.9

# Python SDK (minimal)
sudo dnf -y install python3-devel gcc make git curl wget

```

#### Install `wheel` and `setuptools`

[Wheel files](https://realpython.com/python-wheels/#what-is-a-python-wheel) (`*.whl`) make for faster, smaller installs.

```bash
python -m venv env && source ./env/bin/activate
# Install or update to latest version
python -m pip install -U pip wheel setuptools
```

## Run at Commandline

### Invoke a Python (interpreter) shell

```bash
$ /usr/bin/env python
Python 3.9.18 (main, May 16 2024, 00:00:00)
[GCC 11.4.1 20231218 (Red Hat 11.4.1-3)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> print("Hello")
Hello
>>>
```
- Exit by `<CTRL-D>`.

### Run a script (`run.py`) from bash shell

```bash
cat <<EOH |tee run.py
#!/usr/bin/env python
import sys
print("Hello from", sys.version)
EOH
chmod 755 run.py
./run.py
```

## Build @ Docker container

Environment is isolated inherently, 
so `requirements.txt` contains only the app's dependencies, 
unlike running that at host.

```bash
pushd app
python3 -m pip install Flask
python3 -m pip freeze |tee requirements.txt
touch app.py
```

See `Python.Docker` ([HTML](Python.Docker.html "@ browser") | [MD](Python.Docker.md))   

## Build @ Host OS

Use `venv` or some such to isolate the environment, 
so `requirements.txt` contains only the app's dependencies, 
else it contains all dependencies of both app and host environment.

```bash
$ pushd app
$ python3 -m venv .venv
$ source .venv/bin/activate
(.venv) $ python3 -m pip install Flask
(.venv) $ python3 -m pip freeze |tee requirements.txt
(.venv) $ touch app.py
```

## Build using wheel files (`.whl`)

Wheel files are compiled binaries,
which make for __quicker subsequent builds__.
However, they are __less portable__. 

For example, wheels built of Debian may not be supported by Alpine, 
yet the same application may install on Alpine 
when not using those Debian-built wheel files.

```bash
mkdir -p /app/wheels

# Compile
python -m pip wheel \
    --no-cache-dir \
    --no-deps \
    --wheel-dir /app/wheels \
    -r requirements.txt

## Install 
python -m pip install --no-cache /app/wheels/*

```
- Add `--force-reinstall` if some are already installed

### Workflow 

Building @ host OS

```bash
###############################################
# PREP lest environment is otherwise isolated
###############################################
# venv ("V Env"): Setup a virtual environment (per project)
## Activated, it sets and isolates versions;
## for python itself and all project dependencies.
## Useful when NOT in an already-isolated environment.
## Keep each venv in its own subfolder under ~/.venvs/ 
path=/path/to/project/root
mkdir $path
cd $path 
python3 -m venv ~/.venvs/venv_${path##*/}

# (Re)Activate WHENEVER WORKING on this project.
source ~/.venvs/venv_${path##*/}/bin/activate

# Deactivate WHENEVER NOT WORKING on this project.
#deactivate

##########
# DEVELOP
##########
# Install module(s) as needed to develop
python3 -m pip install $module[==VERSION]
## Or 
python3 -m pip wheel $module[==VERSION]

# Run app
python3 app.py #... or ...
# Run app as background process 
nohup python3 app.py > app.log 2>&1 &
#... fg;CTRL-C to kill.

# (Re)Generate the 'requirements.txt' to include all app.py dependencies.
python3 -m pip freeze > requirements.txt

# Thereafter, in any other environment, install all project dependencies.
python3 -m pip install -r requirements.txt

# Deactivate WHENEVER NOT WORKING on this project.
deactivate
```

Alternative way to manage `requirements.txt`,
or to generate initially.

```bash
# Install pipreqs : to generate 'requirements.txt' 
python3 -m pip install pipreqs
# Generate the requirements.txt
## The list of all PRIMARY modules (versioned) required to run 
## this project (./*.py) in the context of this Python (python) version.
## That is, it DOES NOT INCLUDE DEPENDENCIES of those modules.
pipreqs .

# Verify
cat requirements.txt
```

## `pip` Hacks

### 1. Declare  PyPI server

If not at its nominal location, must use options to inform `pip`:

```bash
python3 -m pip install \
    --trusted-host $hostname \
    --index-url $url \
    -r requirements.txt

```

### 2. App-only depenedencies 

Reveal application-only depenencies. 

>Note: Building in a virgin or managed environment, such as a Docker container, removes the need for this hack  because all dependencies there are application dependencies.

Contrary to claims, __there is no Python tool that lists all versioned dependencies of an application__ *and only those dependencies* in environments that are not virgin. Instead, what is generated by such tools is a list of all dependencies of *all modules of the current environment* regardless of those declared, e.g., in the `requirements.txt` file. This is true for all tools tested, including the oft-advised `pipreqs`.

However, there is a simple hack to solve this problem: Containerize it. Otherwise, if working from a host, perform `pip` install twice on an *unversioned* module(s) list (`requirements.txt`) that contains only the primary (known) module(s).  This forces `pip` to generate the list of application dependencies _and their versions_, from which a `requirements.txt` may be generated (albeit tediously):

Example: 

@ [`requirements.txt`](requirements.txt)

```text
flask
```

```bash
$ python -m pip install -r requirements.txt 
$ python -m pip install -r requirements.txt |tee pip.install.log
```

Upon that second run, `pip` generates the following report, 
listing only the actual dependencies of the app, and their versions, not all dependencies of the environment, as otherwise occurs:

```text
Requirement already satisfied: flask in /usr/local/lib/python3.9/site-packages (2.0.3)
Requirement already satisfied: click>=7.1.2 in /usr/local/lib/python3.9/site-packages (from flask) (8.1.6)
Requirement already satisfied: Werkzeug>=2.0 in /usr/local/lib/python3.9/site-packages (from flask) (2.3.6)
Requirement already satisfied: Jinja2>=3.0 in /usr/local/lib/python3.9/site-packages (from flask) (3.1.2)
Requirement already satisfied: itsdangerous>=2.0 in /usr/local/lib/python3.9/site-packages (from flask) (2.1.2)
Requirement already satisfied: MarkupSafe>=2.0 in /usr/local/lib/python3.9/site-packages (from Jinja2>=3.0->flask) (2.1.3)
```

Use that report as the basis to generate a _versioned_ `requirements.txt` :

```bash
# Extract the module name list
$ cat pip.install.log |awk -F ':' '{print $NF}' |awk -F '>' '{print $1}' |awk '{print $1}' |tee c0
 flask
 itsdangerous
 Werkzeug
 Jinja2
 click
 MarkupSafe

# Extract the module version list 
$ cat pip.install.log |awk '{print $NF}' |tr -d '(' |tr -d ')' |tee c1
2.0.3
2.1.2
2.3.6
3.1.2
8.1.6
2.1.3

# Paste the two lists together 
$ paste c0 c1 |sed 's/[[:space:]]/==/g' |tee app.requirements.txt
flask==2.0.3
itsdangerous==2.1.2
Werkzeug==2.3.6
Jinja2==3.1.2
click==8.1.6
MarkupSafe==2.1.3
```
- This resulting file may require some manual cleanup.

## Applications | [PyPI](https://pypi.org/)

PyPI (Python Index) references *the* server (`pypi.org`) hosting *the* repository of all published Python modules. 
To use an alternative repository, Python tools must be informed (using commandline flags and such). 
Separately, many projects host their own web sites and/or have an additional source (typically OSS) repository.

### [`http.server.py`](https://docs.python.org/3/library/http.server.html)

FS-Directory Server (HTML only)

```bash
python3 -m http.server --bind 127.0.0.1 --directory /a/path/
## --directory /a/path/     @ 3.7+
## --bind 127.0.0.1         @ 3.4+/8+(IPv6)
```

```bash
$ pushd dws
$ python3.11 -m http.server 8888 --bind 127.0.0.1 --directory v1/web
Serving HTTP on 127.0.0.1 port 8888 (http://127.0.0.1:8888/) ...
127.0.0.1 - - [20/Jul/2023 13:03:10] "GET / HTTP/1.1" 200 -
127.0.0.1 - - [20/Jul/2023 13:03:20] "HEAD / HTTP/1.1" 200 -
```
```bash
$ curl -I localhost:8888
HTTP/1.0 200 OK
Server: SimpleHTTP/0.6 Python/3.11.2
...
```

### [`folderview`](https://github.com/MrAmbiG/folderview) : Serve a directory

```python
from flask import Flask 
from flask_autoindex import AutoIndex

app = Flask(__name__)

ppath = "/" # update your own parent directory here

app = Flask(__name__)
AutoIndex(app, browse_root=ppath)    

if __name__ == "__main__":
    app.run()

```

### [Werkzeug](https://werkzeug.palletsprojects.com) : [WSGI](https://wsgi.readthedocs.io/en/latest/index.html "A specification for an interface between app server and web server") Library

>_Werkzeug is a comprehensive <abbr title="Web Server Gateway Interface">WSGI</abbr> web application library. It began as a simple collection of various utilities for WSGI applications and has become one of the most advanced WSGI utility libraries._ 

>_Werkzeug doesn’t enforce any dependencies. It is up to the developer to choose a template engine, database adapter, and even how to handle requests._

(See [WSGI intro](http://wsgi.tutorial.codepoint.net/intro).)

To implement [Gunicorn](https://pypi.org/project/gunicorn/#description "@ PyPI") (Python WSGI HTTP Server) for Flask, use this `CMD` in `Dockerfile` :

```bash
CMD ["gunicorn", "--bind", "0.0.0.0:5555", "{subfolder}.{file_name}:{flask_name}"]
```
- If main module is in root folder with file name `main.py`, and has Flask-instance variable name `myapp`, then the final command arg (above) is just "`main:myapp`". If that app is moved to subfolders, then the arg becomes "`subfolder1_name.subfolder2_name.main:myapp`"
-  Set workers: `-w 4`


## Anaconda

>_A distribution of the Python and R programming languages for scientific computing (data science, machine learning applications, large-scale data processing, predictive analytics, etc.), that aims to simplify package management and deployment._

- `conda` package manager; the `pip` for Anaconda
    - Better dependancy handling than `pip`.

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

