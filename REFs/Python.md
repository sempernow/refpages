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

#### Install `wheel` and `setuptools`

[Wheel files](https://realpython.com/python-wheels/#what-is-a-python-wheel) (`*.whl`) make for faster, smaller installs.

```bash
python -m venv env && source ./env/bin/activate
# Install or update to latest version
python -m pip install -U pip wheel setuptools
```

## Workflow

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

## [Werkzeug](https://werkzeug.palletsprojects.com) : [WSGI](https://wsgi.readthedocs.io/en/latest/index.html "A specification for an interface between app server and web server") Library

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

>_a distribution of the Python and R programming languages for scientific computing (data science, machine learning applications, large-scale data processing, predictive analytics, etc.), that aims to simplify package management and deployment._

- `conda` package manager; the `pip` for Anaconda
    - Better dependancy handling than `pip`.

## `pip` Hacks

If PyPI server is not at its nominal location, 
must use options to inform `pip`:

```bash
python3 -m pip install \
    --trusted-host $hostname \
    --index-url $url \
    -r requirements.txt

```

### App-only dependencies @ `requirements.txt` 

Hack `pip` to reveal application-only depenencies. 

Just install an already-installed (main) module,
e.g., `flask`, or feed `pip` an unversioned list 
(`requirements.txt`) and run it twice. 

This will force `pip` to generate a list of the 
application's installed dependencies (modules) 
_and their versions_, 
from which the `requirements.txt` can be generated:

Example: 

```bash
$ python -m pip install flask |tee pip.install.log

Requirement already satisfied: flask in /usr/local/lib/python3.9/site-packages (2.0.3)
Requirement already satisfied: click>=7.1.2 in /usr/local/lib/python3.9/site-packages (from flask) (8.1.6)
Requirement already satisfied: Werkzeug>=2.0 in /usr/local/lib/python3.9/site-packages (from flask) (2.3.6)
Requirement already satisfied: Jinja2>=3.0 in /usr/local/lib/python3.9/site-packages (from flask) (3.1.2)
Requirement already satisfied: itsdangerous>=2.0 in /usr/local/lib/python3.9/site-packages (from flask) (2.1.2)
Requirement already satisfied: MarkupSafe>=2.0 in /usr/local/lib/python3.9/site-packages (from Jinja2>=3.0->flask) (2.1.3)
```

Use that as the basis to generate a _versioned_ `requirements.txt` :

```bash

$ cat pip.install.log |awk -F ':' '{print $NF}' |awk -F '>' '{print $1}' |awk '{print $1}' |tee c0
 flask
 itsdangerous
 Werkzeug
 Jinja2
 click
 MarkupSafe

$ cat pip.install.log |awk '{print $NF}' |tr -d '(' |tr -d ')' |tee c1
2.0.3
2.1.2
2.3.6
3.1.2
8.1.6
2.1.3

$ paste c0 c1 |sed 's/[[:space:]]/==/g' |tee app.requirements.txt
flask==2.0.3
itsdangerous==2.1.2
Werkzeug==2.3.6
Jinja2==3.1.2
click==8.1.6
MarkupSafe==2.1.3
```

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

