#!/usr/bin/env bash

conda --version     # 24.9.2
conda list          # Installed packages
conda env list      # All environments : Never work in (base) !

# Create a working environment
conda create --name prj-01              # /opt/conda/envs/prj-01
conda create --name prj-02 python=3.9   # Declare its Python version

# Move an environment (old -> new)
conda deactivate    # Leave old environment
conda create --name new --clone old # Clone old to new
conda remove --name old --all       # Delete old
conda activate new  # Enter new environment

# Activate an environment
conda activate prj-01   # python --version : 3.11.2
conda deactivate        # Always deactivate before switching project envs
conda activate prj-02   # python --version : 3.9.25 

# Install packages
conda install jupyterlab dask pandas hvplot 
conda install -c conda-forge condastats # Use a declared conda repository
conda install -c conda-forge nodejs

# Revert to a prior revision (prior environment state)
conda list --revisions      # List them
conda install --revision=1  # Declare the revision; changes to that state.

# Install Jupyter Notebook 
# Install packages to new environment (scratch)
conda install ipykernel notebook

# Register the kernel to this environment (scratch)
python -m ipykernel install --user --name=scratch

# Run Jupyter Notebook
jupyter notebook # Launches Web UI > Menu select : New > scratch

# Run JupyterLab
jupyter-lab 

# Install Spyder IDE
conda install spyder-kernels
# - Run Spyder from Anaconda Navigator
# - Select Spyder
