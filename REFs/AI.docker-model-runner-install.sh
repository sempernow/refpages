#!/usr/bin/env bash
################################################
# This script installs onto Ubuntu:
# - Docker Engine (CE)
#   https://docs.docker.com/engine/install/
# - Docker Model Runner 
#   https://github.com/docker/model-runner
################################################
HEADER='Relog and then ...'

instruct(){
    echo '
    '"$HEADER"'

    # Verify
    docker model --help

    # Pull a model
    docker model pull ai/smollm2
    
    # List models in cache
    docker model ls

    # Run a model
    docker model run ai/smollm2 "Say hello from Docker Model Runner!"

    # Reference
    https://github.com/docker/model-runner/
    '
}

# Inform and exit if docker model is already installed
docker model --help |grep -q 'docker model' && {
    HEADER='docker model is already installed !'
    instruct

    exit 
}

# Delete any existing (Ubuntu-based) install
type -t docker && {
    docker system prune --all -f
    docker system prune --volumes -f
    sudo apt remove --purge docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc
    sudo apt remove --purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo apt autoremove
    sudo apt autoclean
}

# Install Docker CE proper
# 1. Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates gpg curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# 2. Add the repository to apt sources; configure to current Ubuntu version:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
# 3. Install its packages:
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify install
docker version || {
    echo "❌ : Docker CE failed to install : ERR : $?"
    
    exit 11
}

# Add user to group
id |grep -q docker ||
    sudo usermod -aG docker $USER

# Install docker model if not already
type -t model-cli && type -t model-runner || {
    type -t go > /dev/null 2>&1 || {
        echo "❌ : Golang is required to build docker model"
        
        exit 22
    } 
    # Build Docker's model-runner from source
    sudo apt install gcc make
    git clone https://github.com/docker/model-runner.git
    push model-runner/
    make build
    push cmd/cli
    make build

    # Install
    sudo install model-cli /usr/local/bin/ &&
        rm model-cli 
    sudo install model-runner /usr/local/bin/ &&
        rm model-runner
    ln -fs /usr/local/bin/model-cli ~/.docker/cli-plugins/docker-model
    sudo chmod +x ~/.docker/cli-plugins/docker-model
}

model-cli version 2> /dev/null || {
    echo "❌ : model-cli failed to install : ERR : $?"
    
    exit 33
}
type -t model-runner > /dev/null 2>&1 || {
    echo "❌ : model-runner failed to install : ERR : $?"
    
    exit 44
}

instruct
