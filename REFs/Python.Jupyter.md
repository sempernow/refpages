# [Jupyter](https://docs.jupyter.org/en/latest/what_is_jupyter.html "docs.jupyter.org") | [JupyterLab](https://jupyter.org/ "jupyter.org")

>Free and built of open standards, it serves web services   
for ___interactive computing___ __across all programming languages__.

JupyterLab is the latest __web-based IDE__ for notebooks, code, and data. 
Its flexible interface allows users to configure and arrange workflows in data science, scientific computing, computational journalism, and machine learning. 
A modular design invites extensions to expand and enrich functionality.

---

## Use Cases

Jupyter is widely used, but typically as a **complement** to development environments rather than a team's *primary* IDE for day-to-day Python work.

**Where Jupyter shines (and sees heavy adoption):**

- **Data science and ML experimentation** — exploratory analysis, prototyping models, visualizing results. This is its sweet spot.
- **Education and training** — universities and corporate training programs love it for spinning up consistent environments for learners.
- **Shared compute access** — giving teams access to GPU clusters or large-memory machines without everyone needing local resources.
- **Reproducible research** — notebooks as shareable, documented analysis artifacts.

**Where teams typically use something else:**

For production code, libraries, applications, and serious software engineering, most teams still reach for traditional IDEs like VS Code, PyCharm, or Neovim. The reasons:

- Notebooks don't play nicely with version control (diffs are ugly, merge conflicts are painful)
- Testing, linting, and refactoring tooling is weaker
- Code organization patterns (modules, packages) don't map well to notebook cells
- Debugging experience is more limited

**The common pattern** is a hybrid: Jupyter for exploration and prototyping, then graduating code to `.py` modules in a proper IDE once it matures. Some teams use VS Code's remote development or code-server as their centralized dev environment instead, which gives them the shared infrastructure benefits without the notebook constraints.

Given your ML learning project, Jupyter could be useful for the experimentation phase, but you're already doing the right thing building proper Python modules — that'll serve you better long-term.

---

## Install

- __Jupyter Notebook__  
    a simplified, lightweight notebook authoring experience
- __JupyterLab__  
    a feature-rich, tabbed multi-notebook editing environment with additional tools like a customizable interface layout and system console


### Install a Standalone [Jupyter Notebook (Interface)](https://github.com/jupyter/notebook "github.com/jupyter/notebook") on a Host

The bare notebook is obsoleted by JupyterLab

[__Install__](https://docs.jupyter.org/en/latest/install.html) / __Run__:

```bash
jupyter notebook
```
- This starts a jupyter notebook server   
  at its default address: http://127.0.0.1:8888

### Containerized JupyterLab Server : [Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/) | [`quay.io/.../jupyter`](https://quay.io/organization/jupyter)

```bash
## JupyterLab (default)
docker run -p 8888:8888 quay.io/jupyter/scipy-notebook:2025-12-31

## Jupyter Notebook (Classic) 
docker run -it --rm \
    -p 8888:8888 \
    -e DOCKER_STACKS_JUPYTER_CMD=notebook \
    -v "${PWD}":/home/jovyan/work \
    quay.io/jupyter/scipy-notebook:2025-12-31

```
- Browse to the reported link, e.g.,    
`http://localhost:8888/lab?token=abc123...`


### Anaconda Distribution | [Anaconda Docs](https://www.anaconda.com/docs/main) | [`continuumio/anaconda3`](https://hub.docker.com/r/continuumio/anaconda3)

- Large [Python repository](https://anaconda.org "Anaconda.org") with dependency management
    - Data Science and ML focus
- [Conda](https://docs.conda.io/en/latest/ "docs.conda.io") package and environment manager
- Jupyter Notebook and JupyterLab
- Desktop app (Navigator) or CLI
- Works on Windows, macOS, and Linux

Start a Jupyter Notebook server and interact with Anaconda via browser:


```bash
# Run JupyterLab server; bind mount to PWD
docker run --rm -v $(pwd):/mnt -p 8888:8888 continuumio/anaconda3 /bin/bash -c "
    jupyter notebook --ip='*' --port=8888 --no-browser --allow-root
"

# ... similarly, adding configuration
docker run --rm -v $(pwd):/opt/notebooks -p 8888:8888 continuumio/anaconda3 /bin/bash -c "
    conda install jupyter -y --quiet && \
    mkdir -p /opt/notebooks && \
    jupyter notebook \
    --notebook-dir=/opt/notebooks --ip='*' --port=8888 \
    --no-browser --allow-root
"
```

Output of run command has URL including AuthN token :  
http://localhost:8888/tree?token=abc123...

1. Menu select: __View__ > __JupyterLab__  
    (Browse to `/lab`)
1. Button select: __Launcher__ > __Other__ > __Terminal__
    ```bash
    # bash
    (base) root@5d7a981fb001:/# conda --version
    conda 24.11.3
    (base) root@5d7a981fb001:/# python --version
    Python 3.12.7
    (base) root@5efa6d6dc284:/# ls -hl /mnt
    ...
    drwxr-xr-x 1 1000 1000 4.0K Jan  4 16:38 agentic-systems
    ...
    (base) root@5efa6d6dc284:/# 
    ```
    - Ok to bind mount container path that does not exist until `mkdir`  
        ```bash
        (base) root@cbc789e75217:/# ls -hl /opt/notebooks/
        ...
        drwxr-xr-x 1 1000 1000 4.0K Jan  4 16:38 agentic-systems
        ...
        ```

#### Tutorials

- [Get Started with Anaconda](https://learning.anaconda.com/courses/get-started-with-anaconda)
- [Jupyter Notebook Basics](https://learning.anaconda.com/courses/jupyter-notebook-basics)

### [__JupyterHub__ Server on K8s](https://github.com/jupyterhub/zero-to-jupyterhub-k8s) | [Docs](https://z2jh.jupyter.org/en/stable/) 

Designed for developer teams, the Jupiter**Hub** service spawns a Jupiter**Lab** environment per user.

- [Self-hosted K8s](https://z2jh.jupyter.org/en/stable/kubernetes/other-infrastructure/step-zero-other.html)
- [Helm Chart](https://hub.jupyter.org/helm-chart/) [Installation](https://z2jh.jupyter.org/en/stable/jupyterhub/installation.html#install-jupyterhub)
- [Configuration](https://z2jh.jupyter.org/en/stable/resources/reference.html#helm-chart-configuration-reference)

## JupyterLab Interface Sections

---

### 1. **File Browser** (Left Panel)

**Purpose**: Navigate your project directory structure  

**How to use**:  

- Double-click `notebooks/any.ipynb` to open a notebook
- Right-click files to open, rename, or copy
- Drag and drop files between directories

---

### 2. **Main Work Area** (Center)

**Purpose**: Where notebooks, terminals, and other documents are opened

---

### 3. **Launcher** Tab 

Usually opens by default at `localhost:8888/lab`.
The Launcher __contains several sections__:

#### A. [Notebook](https://docs.jupyter.org/en/latest/#what-is-a-notebook) Section

>The Classic Notebook Interface; notebook authoring application.

The Jupyter Notebook is the project's original web application 
for creating and sharing computational documents. 
It offers a simple, streamlined, document-centric experience.

**Purpose**: Create and work with interactive Python notebooks  

**Contains**:  

- **Notebook**s (`*.ipynb`)
- __Kernel__ (`.ipykernel`) : A notebook's [IPython](https://ipython.readthedocs.io/en/stable/index.html) __REPL__
    - Executes the notebook code (cells); 
    - Manages environment  
      Tracks variables and returns results. 
    - Click to create a new notebook

#### B. Console Section (REPL)

**Purpose**: Interactive Python consoles (REPL environment)

**Contains**: **Python 3**: Launch a Python console session

**How to use**:

- Quick debugging without creating a full notebook
- Test small code snippets:
  ```python
  # Quick test of a function
  from src.nn.activations import sigmoid
  print(sigmoid(0))
  ```
- Use when you need to test imports or check module availability


#### C. Other Section

WebUI > Other > Terminal

**Purpose**: Various tools and utilities  

**Contains**:

- **Text File** - Create/edit Python scripts, config files, etc.
   - Use to edit `.py` files directly in browser
- **Markdown File** - Documentation
   - Create `README.md` or documentation
   - Write notes about your neural network implementation
- **Terminal** - ___Most useful___ at Docker setup!
   - Full Linux terminal in the container
   - Access the project directory.
        ```bash
        (base) jovyan@7fe2e861c719:~$ pwd
        /home/jovyan
        ```
        - User "__`joyvan`__" (derived from "Jovian", meaning "like Jupiter") is a community in-joke and a term used to describe community members; a whimsical way of labeling the default user in their pre-built Docker images. 

---

## Usage 

TODO


## **Quick Start Guide**:

1. **Open browser**: `http://localhost:8888`
2. **Open an existing notebook**: Click `notebooks/any.ipynb`
3. **Create new experiments**: Click "Python 3" under Notebook
4. **Debug or run commands**: Open "Terminal" under Other section
5. **Edit source code**: Use "Text File" or terminal editor

<!-- 

… ⋮ ︙ • ● – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × ₽ € ¥ £ ¢ ¤ ♻ ⚐ ⚑ ✪ ❤  \ufe0f
☢ ☣ ☠ ¦ ¶ § † ‡ ß µ Ø ƒ Δ ☡ ☈ ☧ ☩ ✚ ☨ ☦ ☓ ♰ ♱ ✖  ☘  웃 𝐀𝐏𝐏 🡸 🡺 ➔
ℹ️ ⚠️ ✅ ⌛ 🚀 🚧 🛠️ 🔧 🔍 🧪 👈 ⚡ ❌ 💡 🔒 📊 📈 🧩 📦 🥇 ✨️ 🔚

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# README HyperLink

README ([MD](__PATH__/README.md)|[HTML](__PATH__/README.html)) 

# Bookmark

- Target
<a name="foo"></a>

- Reference
[Foo](#foo)

-->
