#!/usr/bin/env bash

set -euo pipefail  # Exit on error, undefined variable, and pipe errors

# ---------------------------
# Configuration
# ---------------------------

# Repository details
REPO_OWNER="FelicianoTech"
REPO_NAME="pocket-casts-desktop-app"

# Temporary files
PACKAGE_LOCK_FILE="package-lock.json"
PACKAGE_JSON_FILE="package.json"

# ---------------------------
# Functions
# ---------------------------

# Function to print error messages and exit
error() {
    echo "Error: $1" >&2
    exit 1
}

# Function to check if a command exists
check_command() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        error "$cmd is not installed. Please install $cmd and try again."
    fi
    echo "$cmd is installed."
}

# Function to check if a Python package is installed via pipx
check_pipx_package() {
    local package="$1"
    if ! pipx list | grep -q "$package"; then
        return 1
    fi
    return 0
}

# ---------------------------
# Check for Required Tools
# ---------------------------

echo "Checking for required tools..."

REQUIRED_TOOLS=(
    "git"
    "pipx"
    "curl"
    "jq"
)

for cmd in "${REQUIRED_TOOLS[@]}"; do
    check_command "$cmd"
done

echo "All required tools are installed."

# ---------------------------
# Initialize Git Submodules
# ---------------------------

echo "Initializing git submodules..."
git submodule update --init || error "Failed to initialize git submodules."
echo "Git submodules initialized successfully."

# ---------------------------
# Install flatpak-node-generator
# ---------------------------

echo "Checking if 'flatpak-node-generator' is installed via pipx..."
if check_pipx_package "flatpak-node-generator"; then
    echo "'flatpak-node-generator' is already installed."
else
    echo "'flatpak-node-generator' is not installed. Installing..."
    pipx install flatpak-builder-tools/node || error "Failed to install 'flatpak-node-generator' via pipx."
    echo "'flatpak-node-generator' installed successfully."
fi

# ---------------------------
# Fetch Latest Release Tag
# ---------------------------

echo "Fetching the latest release tag from GitHub..."
LATEST_TAG=$(curl -s "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest" | jq -r '.tag_name') || error "Failed to fetch the latest release tag."
if [[ -z "$LATEST_TAG" || "$LATEST_TAG" == "null" ]]; then
    error "Latest release tag not found."
fi
echo "Latest release tag: $LATEST_TAG"

# ---------------------------
# Download package.json and package-lock.json
# ---------------------------

echo "Downloading 'package.json' and 'package-lock.json' from the latest release..."
PACKAGE_JSON_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${LATEST_TAG}/package.json"
PACKAGE_LOCK_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${LATEST_TAG}/package-lock.json"

curl -sSL "$PACKAGE_LOCK_URL" -o "$PACKAGE_LOCK_FILE" || error "Failed to download 'package-lock.json'."
curl -sSL "$PACKAGE_JSON_URL" -o "$PACKAGE_JSON_FILE" || error "Failed to download 'package.json'."
echo "Downloaded 'package.json' and 'package-lock.json' successfully."

# ---------------------------
# Generate Sources
# ---------------------------

echo "Generating 'generated-sources.json' using 'flatpak-node-generator'..."
flatpak-node-generator npm "$PACKAGE_LOCK_FILE" || error "'flatpak-node-generator' failed."
echo "'generated-sources.json' generated successfully."

# ---------------------------
# Clean Up
# ---------------------------

echo "Cleaning up downloaded JSON files..."
rm -f "$PACKAGE_LOCK_FILE" "$PACKAGE_JSON_FILE"
echo "Cleaned up temporary files."

# ---------------------------
# Completion Message
# ---------------------------

echo "Node sources updated successfully. Please review and commit 'generated-sources.json'."
