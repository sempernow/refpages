# [Anaconda.com](https://www.anaconda.com/docs/main) | [Docs](https://www.anaconda.com/docs/main) 

A widely-adopted vendor in the Python ecosystem, especially for 
**Data Science**, **Scientific Computing**, and **M**achine **L**earning (**ML**). 

--- 

## Anaconda Distribution

- Python3.X
- CLI + GUI ([Navigator](https://www.anaconda.com/products/navigator))
- [JupyterLab](https://jupyterlab.readthedocs.io/en/latest/) and [Jupyter Notebook](https://jupyter-notebook.readthedocs.io/en/latest/)
- [Spyder](https://www.anaconda.com/docs/getting-started/guides/ides/spyder) : Crappy IDE used by R coders.
- [Conda](https://docs.conda.io/en/latest/ "docs.conda.io") package and environment manager
- [Package repository](https://anaconda.org "Anaconda.org") with dependency management
- Works on Windows, macOS, and Linux

```bash
choco search anaconda
choco install anaconda3

```

Dumps to `C:\tools\Anaconda3`, but we want to work at `%UserProfile%`.

__Fix__:

Create `%UserProfile%\.condarc`

```yaml
envs_dirs:
  - C:\Users\<you>\.conda\envs
  - C:\tools\Anaconda3\envs      # fallback read access to shared envs

pkgs_dirs:
  - C:\Users\<you>\.conda\pkgs

auto_activate_base: false         # optional: cleaner shell startup
```

__Optional__: 

Modifiy `$PROFILE` (PowerShell) or `registry` (cmd) 
to __activate conda on shell startup__.

```powershell
PS> C:\tools\Anaconda3\Scripts\conda.exe init powershell   
```

### Navigator (GUI) : __Environments__ (tab)

- Channels (button) : A channel is a repository
    - Free: 
        - `anaconda.org`
        - `conda-forge`
    - Paywall: `anaconda.cloud`
- Environments
    - Search
    - Select/Launch a terminal configured to the selected environment.
    - Create
    - Clone
    - Import
    - Backup
    - Remove
    - Packages are listed per environment
        - Install
        - Uninstall
        - Update/Change version
- Learning 
- Community

## Miniconda (90% smaller)

- Python3.X
- [Conda](https://docs.conda.io/en/latest/ "docs.conda.io") package and environment manager

```bash
choco search anaconda
choco install miniconda3

```

---

## Containerized | [`continuumio/anaconda3`](https://hub.docker.com/r/continuumio/anaconda3)

__Anaconda in Jupyter__:

```bash
# Run JupyterLab server; bind mount to PWD
docker run -v $(pwd):/mnt -p 8888:8888 continuumio/anaconda3 /bin/bash -c "
    jupyter notebook --ip='*' --port=8888 --no-browser --allow-root
"

# ... similarly, adding configuration
docker run -v $(pwd):/opt/notebooks -p 8888:8888 continuumio/anaconda3 /bin/bash -c "
    conda install jupyter -y --quiet && \
    mkdir -p /opt/notebooks && \
    jupyter notebook \
    --notebook-dir=/opt/notebooks --ip='*' --port=8888 \
    --no-browser --allow-root
"
```
- Conda manages dependencies (install etal), 
  so don't use `--rm` flag, 
  so that (dev) container (state) survives server shutdown.

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

---

## Tutorials

- [Get Started with Anaconda](https://learning.anaconda.com/courses/get-started-with-anaconda)
- [Jupyter Notebook Basics](https://learning.anaconda.com/courses/jupyter-notebook-basics)


```bash
conda --version     # 24.9.2
conda list          # Installed packages
conda env list      # All environments : Never work in (base) !

# Create a working environment
conda create --name prj-01              # /opt/conda/envs/prj-01
conda create --name prj-02 python=3.9   # Declare its Python version

# Activate an environment
conda activate prj-01   # python --version : 3.11.2
conda deactivate        # Always deactivate before switching project envs
conda activate prj-02   # python --version : 3.9.25 

# Install packages
conda install jupyterlab dask pandas hvplot
conda install -c conda-forge condastats # Use a declared conda repository

# Run JupyterLab
jupyter-lab 
```

## Spyder IDE

**S**cientific **PY**thon **D**evelopment **E**nvi**R**onment (Spyder) is an open-source IDE for Python, designed specifically for scientists, engineers, and data analysts. It is included by default in the Anaconda distribution of Python and is a popular choice for scientific computing and data analysis. 

---

## Where does Anaconda fit in Python's Ecosystem?

### 1. Core Purpose & Positioning

Anaconda is **not just a Python distribution** — it’s a **platform and ecosystem** designed to solve key challenges in data science and production Python environments:

- **Package & Environment Management**: Simplifies installation of data science libraries (many of which have complex C/Fortran dependencies).
- **Cross-platform Reproducibility**: Ensures consistent environments across Windows, macOS, and Linux.
- **Enterprise/Production Readiness**: Offers tools for scaling, collaboration, and deployment.

### 2. Key Components & How They Fit

- **Anaconda Distribution / Miniconda**
    - **Anaconda Distribution**: A batteries-included bundle of Python + 250+ pre-installed data science packages (NumPy, Pandas, SciPy, Jupyter, etc.).
    - **Miniconda**: Minimal installer for Conda (just Python + Conda). Users add only what they need.
    - **Fits in**: Alternative to `python.org` Python + `pip` for users who need a managed scientific stack.

- **Conda Package Manager**
    - **Dependency Resolution**: Handles non-Python dependencies (e.g., CUDA, MKL, libpng).
    - **Cross-language**: Can install Python, R, and system libraries.
    - **Virtual Environments**: Native environment management (`conda create -n myenv`).
    - **Fits in**: Coexists/competes with `pip` + `venv`/`virtualenv`. Often preferred in scientific computing due to better handling of binary dependencies.

- **Anaconda.org (formerly Binstar)**
    - Public/private package repository for Conda packages.
    - Hosts community packages (`conda-forge`) and commercial packages.
    - **Fits in**: Like PyPI, but for Conda packages (can also host pip-installable packages).

- **Conda-Forge**
    - Community-led Conda channel with thousands of up-to-date packages.
    - **Fits in**: The "community standard" for Conda packages, similar to PyPI's role for pip.

### 3. Target Users

- **Data Scientists / Researchers**: Who need a stable, reproducible environment with minimal setup friction.
- **Educators / Students**: Easy all-in-one installer for teaching data science.
- **Enterprise Teams**: Using **Anaconda Enterprise** or **Anaconda Navigator** for managed deployments.
- **Library Developers**: Who need to build packages with complex dependencies across platforms.

### 4. Compared to Standard Python Tools

| **Aspect** | **Standard Python (pip/venv)** | **Anaconda (Conda)** |
|------------|-------------------------------|----------------------|
| **Scope** | Python-only packages | Python + system libs + other languages |
| **Env Management** | `venv`, `virtualenv` | `conda env` |
| **Package Repo** | PyPI | Anaconda.org, Conda-Forge |
| **Binary Deps** | Relies on wheels, can be brittle | Built-in management of non-Python deps |
| **Default Use Case** | General Python development | Data science / scientific computing |

### 5. Common Workflow Integration

Many data science projects use a hybrid approach:

- Use `conda` to install "heavy" libraries with native dependencies (NumPy, TensorFlow, PyTorch, GDAL, etc.).
- Use `pip` inside Conda environments for pure-Python packages not available in Conda channels.

Example:

```bash
conda create -n myproject python=3.9 numpy pandas
conda activate myproject
pip install some-pure-python-pkg
```

### 6. Criticisms & Tensions in Ecosystem

- **Package duplication**: Some packages exist in both PyPI and Conda, causing confusion.
- **Channel mixing**: Mixing `conda-forge` with `defaults` can break environments.
- **Not Python-specific**: Some Python purists prefer `pip`/`venv` for simplicity.
- **Commercial vs Open Source**: Anaconda Inc. shifted some packages to paid licensing in 2020 (led to growth of `conda-forge` as alternative).

### **7. Evolution & Current State**

- Originally created by Continuum Analytics (now Anaconda Inc.) to solve scientific Python packaging.
- **Conda** is open source (BSD license), but **Anaconda Distribution** includes some commercial components.
- **Mamba**: A faster drop-in reimplementation of Conda’s solver, gaining popularity.
- **PyPI/pip improvements** (like better binary wheels via `manylinux`) have reduced but not eliminated the need for Conda in data science.

### Summary

**Anaconda fits as a curated, scientifically-focused layer on top of Python**, addressing:

1. **Complex dependency hell** in data science stacks.
2. **Cross-platform reproducibility**.
3. **Enterprise-scale data science workflows**.

It’s **essential for many data scientists** but **optional for general Python developers**.
The ecosystem continues to evolve with healthy _coexistence_ between Conda and `pip`/`venv` workflows.

---

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
