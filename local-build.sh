#!/usr/bin/env bash

set -e  # Exit immediately if a command exits with a non-zero status

BRANCH="test"

# Function to print error messages
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

# Check if flatpak is installed
check_command "flatpak"

# Check if flatpak-builder is installed
check_command "flatpak-builder"

# Define required Flatpak packages
REQUIRED_FLATPAK_PACKAGES=(
    "org.freedesktop.Platform//24.08"
    "org.freedesktop.Sdk//24.08"
    "org.freedesktop.Sdk.Extension.node20//24.08"
    "org.electronjs.Electron2.BaseApp//24.08"
)

# Function to check if a Flatpak package is installed
is_flatpak_installed() {
    local package="$1"
    flatpak info "$package" &> /dev/null
}

# Install missing Flatpak packages
for package in "${REQUIRED_FLATPAK_PACKAGES[@]}"; do
    if is_flatpak_installed "$package"; then
        echo "Flatpak package '$package' is already installed."
    else
        echo "Flatpak package '$package' is not installed. Installing..."
        flatpak install -y flathub "$package" || error "Failed to install $package"
    fi
done

# Update Flatpak repositories
echo "Updating Flatpak repositories..."
flatpak update -y || error "Failed to update Flatpak repositories"

# Clean previous build artifacts
echo "Cleaning previous build artifacts..."
rm -f tech.feliciano.pocket-casts.flatpak
rm -rf _build _repo
mkdir _build _repo

# Build the Flatpak
echo "Building the Flatpak..."
flatpak-builder --ccache --force-clean --default-branch="$BRANCH" _build tech.feliciano.pocket-casts.yml --repo=_repo || error "flatpak-builder failed"

# Bundle the Flatpak
echo "Bundling the Flatpak..."
flatpak build-bundle _repo tech.feliciano.pocket-casts.flatpak tech.feliciano.pocket-casts "$BRANCH" || error "flatpak build-bundle failed"

echo "Flatpak build and bundle completed successfully."
