#!/bin/bash

# --- Colors for Output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# --- Configuration & Defaults ---
# Default base URL (Update this to your actual GitHub username/org if needed)
GITHUB_BASE_URL="https://github.com/adityastomar67"

# XDG Standard Paths
NVIM_CONFIG_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
NVIM_CACHE_DIRS=(
  "${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
  "${XDG_STATE_HOME:-$HOME/.local/state}/nvim"
  "${XDG_CACHE_HOME:-$HOME/.cache}/nvim"
)

# --- Helper Functions ---

Logger::info() { echo -e "${YELLOW}[INFO] $1${RESET}"; }
Logger::success() { echo -e "${GREEN}[SUCCESS] $1${RESET}"; }
Logger::error() { echo -e "${RED}[ERROR] $1${RESET}"; }

Installer::install_binary() {
    local version_type="$1" # 'stable' or 'nightly'
    local download_url=""

    if [[ "$version_type" == "stable" ]]; then
        download_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
    else
        download_url="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz"
    fi

    Logger::info "Downloading Neovim ($version_type)..."

    # Create a temporary directory for safe downloading
    local temp_dir
    temp_dir=$(mktemp -d)

    if ! curl -L "$download_url" -o "$temp_dir/nvim-linux64.tar.gz"; then
        Logger::error "Download failed."
        rm -rf "$temp_dir"
        return 1
    fi

    Logger::info "Installing to /opt/nvim-linux64 (requires sudo)..."

    # Clean previous installs in /opt
    if [ -d "/opt/nvim-linux64" ]; then
        sudo rm -rf "/opt/nvim-linux64"
    fi

    # Extract new version to /opt
    sudo tar -C /opt -xzf "$temp_dir/nvim-linux64.tar.gz"

    # Symlink to /usr/local/bin so it's in PATH
    # Remove old symlink if it exists
    if [ -L "/usr/local/bin/nvim" ]; then
        sudo rm "/usr/local/bin/nvim"
    fi
    sudo ln -s /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim

    # Cleanup temp files
    rm -rf "$temp_dir"

    Logger::success "Neovim ($version_type) installed successfully."
}

Installer::setup_config() {
    local repo_choice="$1"
    local repo_url=""

    if [[ "$repo_choice" == "l" ]]; then
        repo_url="$GITHUB_BASE_URL/LazyNV.git"
    elif [[ "$repo_choice" == "n" ]]; then
        repo_url="$GITHUB_BASE_URL/NvStar.git"
    else
        Logger::error "Invalid configuration choice."
        return 1
    fi

    Logger::info "Backing up existing configuration..."
    if [ -d "$NVIM_CONFIG_PATH" ]; then
        mv "$NVIM_CONFIG_PATH" "${NVIM_CONFIG_PATH}.backup.$(date +%s)"
    fi

    Logger::info "Cleaning old cache and state files..."
    for dir in "${NVIM_CACHE_DIRS[@]}"; do
        rm -rf "$dir"
    done

    Logger::info "Cloning configuration..."
    if git clone "$repo_url" "$NVIM_CONFIG_PATH"; then
        Logger::success "Configuration installed!"
    else
        Logger::error "Failed to clone repository."
        return 1
    fi
}

# --- Main Execution ---

# 1. Check/Install Neovim
if ! command -v nvim >/dev/null 2>&1; then
    echo -e "${RED}Neovim is not installed.${RESET}"

    while true; do
        read -p "Install Neovim? (s)table / (n)ightly / (q)uit: " neovim_version_choice
        case "$neovim_version_choice" in
            s|S) Installer::install_binary "stable"; break ;;
            n|N) Installer::install_binary "nightly"; break ;;
            q|Q) echo "Exiting."; exit 0 ;;
            *) echo "Invalid option. Please enter 's' or 'n'." ;;
        esac
    done
else
    echo -e "${GREEN}Neovim is already installed.$(command -v nvim)${RESET}"
fi

# 2. Install Configuration
echo
echo "Which Neovim configuration would you like to install?"
while true; do
    read -p "Enter 'l' for LazyNV, 'n' for NvStar, or 'q' to skip: " config_repo_choice
    case "$config_repo_choice" in
        l|L) Installer::setup_config "l"; break ;;
        n|N) Installer::setup_config "n"; break ;;
        q|Q) echo "Skipping configuration setup."; break ;;
        *) echo "Invalid option. Please enter 'l' or 'n'." ;;
    esac
done

echo
Logger::success "Setup complete."
