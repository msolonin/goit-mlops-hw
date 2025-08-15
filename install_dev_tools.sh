#!/bin/bash

set -e
export DEBIAN_FRONTEND=noninteractive

SCRIPT_LOG="install.log"
touch $SCRIPT_LOG

MESSAGE() {
    local timeAndDate
    timeAndDate=$(date '+%Y-%m-%dT%H:%M:%S')
    local message="$timeAndDate [$1] $2"
    echo "$message" | tee -a "$SCRIPT_LOG"
}


apt update -y

# Docker installation:
if ! command -v docker &> /dev/null; then
    MESSAGE INFO "Installing Docker..."
    sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    dockerVersion=$(docker --version)
    MESSAGE "Docker version $dockerVersion installed."
else
    dockerVersion=$(docker --version)
    MESSAGE INFO "Docker $dockerVersion is already installed."
fi

# Docker Compose installation:
if ! command -v docker-compose &> /dev/null; then
    MESSAGE INFO "Installing Docker Compose..."
    dockerComposeVersion=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')
    MESSAGE INFO "Docker Compose version $dockerComposeVersion..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v${dockerComposeVersion}/docker-compose-$(uname -s)-$(uname -m)" \
      -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    MESSAGE INFO "Docker Compose version $dockerComposeVersion installed."
else
    dockerComposeVersion=$(docker-compose --version)
    MESSAGE INFO "$dockerComposeVersion is already installed."
fi

# Python installation:
if command -v python3 &> /dev/null; then
    pythonVersion=$(python3 -V 2>&1 | awk '{print $2}')
    if [[ "$(printf '%s\n' "3.9" "$pythonVersion" | sort -V | head -n1)" == "3.9" ]]; then
        MESSAGE INFO "Python $pythonVersion is already installed."
    else
        MESSAGE WARNING "Installed Python ($pythonVersion) is older than 3.9, updating..."
        sudo apt install -y python3 python3-pip
    fi
else
    MESSAGE INFO "Python is not installed, installing..."
    sudo apt install -y python3 python3-pip
fi

# PIP installation if it not exist separately from Python:
if command -v pip3 &> /dev/null; then
    pipVersion=$(pip3 --version)
    MESSAGE INFO "PIP $pipVersion is already installed."
else
    MESSAGE INFO "PIP is not installed, installing..."
    sudo apt install -y python3-pip
    pipVersion=$(pip3 --version)
    MESSAGE INFO "PIP $pipVersion installed."
fi

# Check installed libraries:
for pkg in torch torchvision pillow; do
    if ! pip3 show "$pkg" > /dev/null 2>&1; then
        MESSAGE INFO "$pkg not found. Installing..."
        pip3 install "$pkg"
        version=$(pip3 show "$pkg" | grep -i '^Version:' | awk '{print $2}')
        MESSAGE INFO "$pkg version $ver installed."
    else
      version=$(pip3 show "$pkg" | grep -i '^Version:' | awk '{print $2}')
        MESSAGE INFO "$pkg is already installed. Version: $ver"
    fi
done

# Django installation:
if python3 -m django --version &> /dev/null; then
    djangoVersion=$(python3 -m django --version)
    MESSAGE INFO "Django $djangoVersion is already installed."
else
    MESSAGE INFO "Django is not installed, installing..."
    sudo apt install -y python3-django
    djangoVersion=$(python3 -m django --version)
    MESSAGE INFO "Django $djangoVersion installed."
fi
