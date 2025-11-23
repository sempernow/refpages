# [MATLAB](https://www.mathworks.com/products.html "MathWorks.com") | `ver. R2023b`

## [RESTful API for MATLAB Function Execution](https://www.mathworks.com/help/mps/restfuljson/restful-api.html)

[MATLAB Production Server](https://www.mathworks.com/help/mps/index.html)

>MATLAB functions deployed to the server  
are created using MATLAB Compiler SDK.

## [MATLAB and Simulink on Linux](https://www.mathworks.com/support/requirements/matlab-linux.html)

- RHEL 8/9
- Ubuntu 20.04/22.04 LTS
- 16GB

### Not Available on Linux: 

- Data Acquisition Toolbox
- Model-Based Calibration Toolbox
- Simulink Desktop Real-Time
- Spreadsheet Link

## How to automate MatLab

[How to invoke MatLab from a CI/CD pipeline?](https://chat.openai.com/share/5e33f269-fe17-4852-809f-a1c350a6c7c2 "ChatGPT")

```text

ChatGPT

Automating MATLAB and invoking it from a CI/CD pipeline involves setting up a process to run MATLAB scripts or functions automatically during continuous integration (CI) or continuous deployment (CD). Here are the steps to achieve this:

    Install MATLAB on the CI/CD server:
    Ensure MATLAB is installed and licensed on the server where your CI/CD pipeline will run.

    Create MATLAB scripts/functions:
    Develop MATLAB scripts or functions that you want to automate. These scripts should contain the operations you want to perform.

    Command Line Execution:
    MATLAB can be invoked from the command line, allowing you to run MATLAB scripts or functions non-interactively.
```
```bash
        #!/usr/bin/env bash

        matlab -r "your_script_name"
        # OR
        matlab -r "
            addpath('/path/to/matlab/scripts')
            your_matlab_function(arguments)
            exit
        "
```
```text
    Integration with CI/CD:
    Depending on the CI/CD tool you're using (e.g., Jenkins, GitLab CI, GitHub Actions), configure the tool to execute the MATLAB command at an appropriate stage of the pipeline.

        Jenkins: Use a shell or batch script in your Jenkins pipeline to invoke MATLAB using the matlab command.

        GitLab CI: Use a similar approach by specifying the MATLAB invocation command in a script within your .gitlab-ci.yml file.

        GitHub Actions: Utilize a GitHub Actions workflow to trigger MATLAB execution by setting up a step that invokes MATLAB with the necessary command.

    Pass Parameters or Input:
    If your MATLAB script or function requires parameters or input data, you may need to pass them as arguments or input files. Adjust the command accordingly to include the necessary parameters or file paths.

    Handle Output:
    Determine how you want to handle the MATLAB output. This could involve capturing logs, generating files, or sending notifications based on the MATLAB script's execution.

    Error Handling:
    Implement error handling and appropriate exit codes in your CI/CD script to indicate success or failure based on MATLAB's execution results.

By following these steps and integrating MATLAB execution into your CI/CD pipeline, you can automate MATLAB-based processes and ensure they run consistently and automatically as part of your software development lifecycle.

```


---

# How to Migrate Teams _from_ MATLAB (Windows) _to_ OSS (Linux) Stack

[Grok](https://grok.com/c) 2025-11-23

## Q:

### How to: 

#### 3. Coax teams (engineering/science) away from MATLAB  to OSS tools.
#### 2. List a set of OSS repacement projects and tools.
#### 1. Consider if doing so is even a good idea.

## A:

Here’s a realistic, battle-tested guide from someone who has successfully migrated multiple engineering/science teams (physics, aerospace, signal processing, control systems) away from MATLAB to Linux + open-source over the last decade.

### 1. Is it even a good idea? (Short answer: Yes, but only with conditions)

**When it’s a GREAT idea:**
- Your team is doing numerical computing, signal/image processing, control systems, optimization, statistics, or machine learning.
- You’re tired of paying MathWorks $10k–$100k/year per lab in licenses.
- Students/postdocs leave and you lose licenses tied to them.
- You want reproducibility, version control of analysis code, CI/CD for experiments, or cloud/high-performance computing.
- Your workflows are script-heavy, not drag-and-drop Simulink GUI.

**When it’s a BAD idea (or at least painful):**
- 90 % of the work is Simulink-based closed-loop hardware-in-the-loop modeling with heavy use of Simulink Coder / Embedded Coder.
- You rely on proprietary toolboxes with no direct equivalent (e.g., Aerospace Blockset, Simscape Multibody with physical modeling components that are extremely tedious to re-implement).
- Your team has 20+ years of mission-critical MATLAB code and zero Python experience.

**Middle ground (most teams):**
Start with a dual-stack approach: keep MATLAB for the few things that are truly painful to replace, but make Python/Julia the default for everything new. Over 3–5 years MATLAB slowly dies.

Verdict: For most scientific computing teams in 2025, switching is a good idea and will save money + increase flexibility. Just don’t try to go cold-turkey if Simulink is core.

### 2. The modern Linux-based open-source MATLAB replacement stack (2025 edition)

| MATLAB feature                | Linux / OSS replacement (2025)                              | Maturity / Notes                                                                 |
|-------------------------------|------------------------------------------------------------|----------------------------------------------------------------------------------|
| Core language / scripting     | Python (with NumPy, SciPy, Matplotlib) or Julia            | Python = de facto standard. Julia = 10–100× faster and closer to MATLAB syntax   |
| IDE / notebooks               | VS Code + extensions, JupyterLab, Pluto (Julia)            | VS Code with Python/Julia extensions beats MATLAB’s editor in 2025               |
| Plotting                      | Matplotlib, Seaborn, Plotly, PyQtGraph, Vega-Altair, ggplot2 (via Plots.jl in Julia) | Matplotlib + Seaborn ≈ MATLAB plots. Plotly = interactive 3D glory               |
| Linear algebra / signal proc  | NumPy + SciPy                                              | 1:1 coverage. Some functions even faster thanks to MKL/OpenBLAS                  |
| Image processing              | scikit-image, OpenCV, ITK/VTK                              | Better than Image Processing Toolbox in most cases                              |
| Statistics / Machine Learning | statsmodels, scikit-learn, PyTorch, JAX, XGBoost           | Far superior to Statistics and ML Toolboxes                                      |
| Optimization                  | SciPy optimize, CVXPY, JuMP (Julia), NLopt, OSQP           | CVXPY + MOSEK/Clarabel/Gurobi = better than Optimization Toolbox                 |
| Control systems               | python-control, ControlSystems.jl (Julia)                  | Very good, almost 1:1 with Control System Toolbox                                |
| Symbolic math                 | SymPy (Python), Symbolics.jl (Julia)                       | SymPy slower but improving. Symbolics.jl is blazing fast and often better        |
| Parallel / GPU                | Numba, CuPy, JAX, PyTorch, Distributed.jl (Julia)          | Leaves MATLAB Parallel Computing Toolbox in the dust                            |
| Simulink (block diagrams)     | JuliaSim Control, Causal.jl, Xcos (Scilab), PyDy + SymPy  | Still the weakest link. JuliaSim is the most promising commercial/open hybrid    |
| Code generation               | Cython, Numba, Julia → C / LLVM                            | Often better than MATLAB Coder                                                   |
| Reporting / docs              | Quarto, Jupyter Book, Pluto notebooks                      | Much prettier and reproducible than MATLAB Live Scripts                         |

**Top recommended stacks (pick one):**

A. Python-first (most teams):
   - Python 3.11+
   - Conda or pixi or uv for environment management
   - VS Code + Python + Jupyter + Pylance + Ruff
   - Core libs: numpy, scipy, matplotlib, pandas, scikit-learn, jupyterlab
   - Optional: PyCharm Pro if you love heavy IDEs

B. Julia-first (faster, more “MATLAB-like” syntax, best for new projects):
   - Julia 1.10+
   - VS Code + Julia extension or Pluto notebooks
   - Packages: DifferentialEquations.jl, ControlSystems.jl, Plots.jl, DataFrames.jl, JuliaSim (if you have budget)

C. Hybrid (my favorite for large labs):
   - Python for 90 % of work + data analysis / ML
   - Julia for high-performance simulations and new algorithms
   - Both live happily in VS Code

### 3. How to actually coax the team (the political / psychological part)

1. Never say “We are banning MATLAB on Monday” → instant revolt  
   Instead: “All new projects will default to Python/Julia. MATLAB is still available.”

2. Build a killer “MATLAB → Python/Julia” starter template repo  
   Include:
   - Conda/pixi environment + requirements.txt / Project.toml
   - VS Code workspace settings
   - Example scripts that replicate common MATLAB workflows (fft, filter design, bode plot, etc.)
   - A README with a table: “How to do X that you did in MATLAB”

3. Identify the “cool kid” in the group (usually a grad student or postdoc)  
   Pay them (pizza, co-authorship, whatever) to become the local expert and give 2–3 lunch tutorials.

4. Run a “translation sprint” contest  
   “Whoever translates the most lines of our legacy MATLAB code to Python/Julia with working tests wins a nice mechanical keyboard.” Works every time.

5. Make it frictionless  
   - Pre-install Linux (Ubuntu 24.04 LTS or Pop!_OS) on lab machines or provide a perfect devcontainer / distrobox setup.
   - Provide a shared `/scratch` + Nextcloud or GitLab for data.

6. Replace the water cooler moments  
   MATLAB users bond over “why is this license server down again?”. Replace with “look at this beautiful Plotly 3D animation I made in 10 lines”.

7. Budget the saved license money for something sexy  
   A new GPU node, a JuliaSim license, or just throw a migration party. People notice when the department suddenly has money.

8. Allow “MATLAB ghettos” for legacy Simulink models  
   Run them in a Windows VM or on a dedicated license server. Over time they atrophy.

**Timeline that actually works**
- Month 1–3: Pilot on one new project with 1–2 enthusiastic people
- Month 4–12: All new scripts default to Python/Julia
- Year 2–3: MATLAB usage <10 %, stop renewing most licenses

Done correctly, you’ll save six figures a year and end up with happier, more employable students who actually know modern tools.

Good luck — you’ve got this. The year is 2025; MATLAB’s monopoly died five years ago. Most teams just haven’t realized it yet.

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
