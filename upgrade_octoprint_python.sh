#!/bin/bash

# This script automates the process of upgrading Python for OctoPrint on Raspbian GNU/Linux 10 (Buster)
# using pyenv, as detailed in upgrade_python_on_Raspbian.md.
# It attempts to locate the OctoPrint installation and its virtual environment.
# Remember to:
# chmod +x /upgrade_octoprint_python.sh


set -e

echo "Starting OctoPrint Python Upgrade Script..."

# --- Step 1: Install Prerequisites ---
echo "\n--- Step 1: Installing Prerequisites ---"
sudo apt update
sudo apt upgrade -y
sudo apt install -y make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev \
xgcc libgdbm-dev libc6-dev libffi-dev python3-dev python3-pip

# --- Step 2: Install pyenv ---
echo "\n--- Step 2: Installing pyenv ---"
if [ ! -d "$HOME/.pyenv" ]; then
    curl https://pyenv.run | bash
else
    echo "pyenv is already installed."
fi

# --- Step 3: Configure Your Shell for pyenv ---
echo "\n--- Step 3: Configuring Shell for pyenv ---"
# Check if pyenv configuration is already in .bashrc to avoid duplication
if ! grep -q "PYENV_ROOT" ~/.bashrc; then
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
    echo "pyenv configuration added to ~/.bashrc. Sourcing it now."
else
    echo "pyenv configuration already exists in ~/.bashrc."
fi
source ~/.bashrc

# --- Step 4: Install a Stable Python Version (e.g., 3.12.3) ---
PYTHON_VERSION="3.12.3"
PYTHON_PATH="$HOME/.pyenv/versions/$PYTHON_VERSION/bin/python"
echo "\n--- Step 4: Installing Python $PYTHON_VERSION via pyenv ---"
if ! pyenv versions | grep -q "$PYTHON_VERSION"; then
    pyenv install $PYTHON_VERSION
else
    echo "Python $PYTHON_VERSION is already installed via pyenv."
fi

# --- Step 5: Verify Python Installation ---
echo "\n--- Step 5: Verifying Python Installation ---"
pyenv versions
if [ -f "$PYTHON_PATH" ]; then
    echo "Python $PYTHON_VERSION executable found at $PYTHON_PATH"
else
    echo "Error: Python $PYTHON_VERSION executable not found at $PYTHON_PATH. Exiting."
    exit 1
fi

# --- Step 6: Stop OctoPrint ---
echo "\n--- Step 6: Stopping OctoPrint ---"
if systemctl is-active --quiet octoprint; then
    sudo systemctl stop octoprint
    echo "OctoPrint service stopped."
else
    echo "OctoPrint service not running or not found. Proceeding."
fi

# --- Step 7: Install OctoPrint's venv-tool ---
echo "\n--- Step 7: Installing OctoPrint's venv-tool ---"
if [ ! -f "./octoprint-venv-tool" ]; then
    curl -LO https://get.octoprint.org/octoprint-venv-tool
    chmod +x octoprint-venv-tool
    echo "octoprint-venv-tool downloaded and made executable."
else
    echo "octoprint-venv-tool already exists."
fi

# --- Step 8: Locate OctoPrint Installation and Recreate Virtual Environment ---
echo "\n--- Step 8: Locating OctoPrint and Recreating Virtual Environment ---"
OCTOPRINT_DIR=""
OCTOPRINT_VENV=""

# Common OctoPrint installation paths
OCTOPRINT_CANDIDATES=("/home/pi/OctoPrint" "/opt/octoprint" "$HOME/OctoPrint")

for candidate_dir in "${OCTOPRINT_CANDIDATES[@]}"; do
    if [ -d "$candidate_dir" ]; then
        echo "Found potential OctoPrint directory: $candidate_dir"
        OCTOPRINT_DIR="$candidate_dir"
        break
    fi
done

if [ -z "$OCTOPRINT_DIR" ]; then
    echo "Warning: Could not automatically locate OctoPrint installation directory."
    read -p "Please enter the full path to your OctoPrint installation directory (e.g., /home/pi/OctoPrint): " OCTOPRINT_DIR
    if [ ! -d "$OCTOPRINT_DIR" ]; then
        echo "Error: OctoPrint directory '$OCTOPRINT_DIR' not found. Exiting."
        exit 1
    fi
fi

# Common OctoPrint virtual environment paths within the installation directory
VENV_CANDIDATES=("$OCTOPRINT_DIR/venv" "$OCTOPRINT_DIR/oprint" "$HOME/oprint")

for candidate_venv in "${VENV_CANDIDATES[@]}"; do
    if [ -d "$candidate_venv" ]; then
        echo "Found potential OctoPrint virtual environment: $candidate_venv"
        OCTOPRINT_VENV="$candidate_venv"
        break
    fi
done

if [ -z "$OCTOPRINT_VENV" ]; then
    echo "Warning: Could not automatically locate OctoPrint virtual environment."
    read -p "Please enter the full path to your OctoPrint virtual environment (e.g., /home/pi/oprint): " OCTOPRINT_VENV
    if [ ! -d "$OCTOPRINT_VENV" ]; then
        echo "Error: OctoPrint virtual environment '$OCTOPRINT_VENV' not found. Exiting."
        exit 1
    fi
fi

echo "Attempting to recreate OctoPrint virtual environment at $OCTOPRINT_VENV using Python $PYTHON_VERSION..."
read -p "This will reinstall OctoPrint and its plugins. Are you sure you want to proceed? (y/N): " confirm
if [[ ! "$confirm" =~ ^[yY]$ ]]; then
    echo "Operation cancelled by user. Exiting."
    exit 0
fi

./octoprint-venv-tool recreate-venv "$OCTOPRINT_VENV" --python "$PYTHON_PATH"

# --- Step 9: Start OctoPrint and Verify ---
echo "\n--- Step 9: Starting OctoPrint ---"
sudo systemctl start octoprint
echo "OctoPrint service started. Please check your OctoPrint web interface to verify the Python version."

# --- Step 10: Possible Issue: User password invalid for WebUI ---
echo "\n--- Step 10: User Password Reset Instructions (if needed) ---"
echo "If you encounter a 'bad username password' error on the web interface, follow these steps:"
echo "1. Activate the virtual environment: source $OCTOPRINT_VENV/bin/activate"
echo "2. Run the password reset command: octoprint user password <your_username>"
echo "3. Enter your new password when prompted."
echo "4. Restart OctoPrint: sudo systemctl restart octoprint"

echo "\nScript finished. Remember to always back up your OctoPrint data before major changes."
