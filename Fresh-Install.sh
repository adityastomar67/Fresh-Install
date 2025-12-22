#!/usr/bin/env bash
# ==============================================================================
#  SCRIPT: fresh-install.sh
#  AUTHOR: Aditya Singh Tomar (@adityastomar67)
#  DESC:   Cross-platform environment bootstrapper (Arch Linux, macOS, Debian).
#          Handles Dotfiles, Neovim, Wallpapers, and System Dependencies.
#  LICENSE: MIT
# ==============================================================================

# --> STRICT MODE <--
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error.
# -o pipefail: Pipeline returns status of the last command to exit with error.
set -euo pipefail

# 1. Detect if we are running on an old Bash version (macOS default is 3)
if [ -n "$BASH_VERSION" ] && [ "${BASH_VERSINFO[0]}" -lt 4 ]; then

    # 2. Check if Zsh is available on the system
    if command -v zsh >/dev/null 2>&1; then
        echo " [INFO] Old Bash detected. Restarting with Zsh..."
        # Re-run this script using zsh, passing all original arguments
        exec zsh "$0" "$@"
    else
        # 3. If no Zsh and old Bash, we must fail gracefully
        echo " [ERROR] This script requires Bash 4.0+ or Zsh."
        echo "         macOS ships with Bash 3.2."
        echo "         Please install Zsh or a newer Bash version (brew install bash)."
        exit 1
    fi
fi

# ==============================================================================
# [MODULE] CONFIGURATION & CONSTANTS
# Read-only configuration variables used throughout the script.
# ==============================================================================
declare -r SCRIPT_NAME="fresh-install"
declare -r GITHUB_URL="https://www.github.com/adityastomar67"

# --- [UPDATE] Defined separate repos for Linux and macOS ---
declare -r DOTS_URL_LINUX="$GITHUB_URL/.dotfiles.git"
# REPLACE THIS with your actual macOS dotfiles repo URL
declare -r DOTS_URL_MAC="$GITHUB_URL/.dotfiles-mac.git"

declare -r BACKUP_DIR="$HOME/.config/backup_$(date +%s)"

# Global State Variables (Mutable)
# g_os_type: Stores 'Darwin' (macOS) or 'Linux'
declare g_os_type=""
# g_install_cmd: Stores the exact command string to install packages (e.g., 'brew install')
declare g_install_cmd=""


# ==============================================================================
# [MODULE] LOGGER
# Handles text formatting, colors, and user output.
# ==============================================================================
Logger::init() {
    # Check if terminal supports colors (tput)
    if tput setaf 1 &>/dev/null; then
        readonly BOLD=$(tput bold)
        readonly RESET=$(tput sgr0)
        readonly RED=$(tput setaf 1)
        readonly GREEN=$(tput setaf 76)
        readonly BLUE=$(tput setaf 38)
        readonly YELLOW=$(tput setaf 3)
    else
        readonly BOLD="" RESET="" RED="" GREEN="" BLUE="" YELLOW=""
    fi
}

# @desc Print info message (Blue)
Logger::info() { echo -e "${BLUE}[INFO]${RESET} $1"; }

# @desc Print success message (Green)
Logger::success() { echo -e "${GREEN}[SUCCESS]${RESET} $1"; }

# @desc Print warning message (Yellow)
Logger::warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }

# @desc Print error message (Red) and output to stderr
Logger::error() { echo -e "${RED}[ERROR]${RESET} $1" >&2; }

# @desc Display the ASCII art header
Logger::header() {
    clear
    cat <<EOF
${BLUE}
███████╗██████╗ ███████╗ ██████╗██╗  ██╗      ██╗███╗  ██╗ ██████╗████████╗ █████╗ ██╗     ██╗
██╔════╝██╔══██╗██╔════╝██╔════╝██║  ██║      ██║████╗ ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║
█████╗  ██████╔╝█████╗  ╚█████╗ ███████║█████╗██║██╔██╗██║╚█████╗    ██║   ███████║██║     ██║
██╔══╝  ██╔══██╗██╔══╝   ╚═══██╗██╔══██║╚════╝██║██║╚████║ ╚═══██╗   ██║   ██╔══██║██║     ██║
██║     ██║  ██║███████╗██████╔╝██║  ██║      ██║██║ ╚███║██████╔╝   ██║   ██║  ██║███████╗███████╗
╚═╝     ╚═╝  ╚═╝╚══════╝╚═════╝ ╚═╝  ╚═╝      ╚═╝╚═╝  ╚══╝╚═════╝    ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝
${RESET}
EOF
}


# ==============================================================================
# [MODULE] SYSTEM
# Handles Operating System detection and abstraction of Package Managers.
# ==============================================================================

# @desc Detects the OS and sets global variable g_os_type
System::detect_os() {
    g_os_type=$(uname -s)
    Logger::info "Detected Operating System: $g_os_type"
}

# @desc Identifies the available package manager and constructs the install command.
#       Populates g_install_cmd.
System::detect_pkg_manager() {
    if [[ "$g_os_type" == "Darwin" ]]; then
        # Check for Homebrew on macOS
        if ! command -v brew &>/dev/null; then
            Logger::info "Homebrew not found. Installing..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        g_install_cmd="brew install"

    elif [[ "$g_os_type" == "Linux" ]]; then
        # Check for common Linux package managers
        if command -v pacman &>/dev/null; then
            g_install_cmd="sudo pacman -Sy --noconfirm --needed"
        elif command -v apt-get &>/dev/null; then
            g_install_cmd="sudo apt-get install -y"
        elif command -v dnf &>/dev/null; then
            g_install_cmd="sudo dnf install -y"
        else
            Logger::error "Unsupported Linux Package Manager. Please install dependencies manually."
            exit 1
        fi
    else
        Logger::error "Unsupported Operating System: $g_os_type"
        exit 1
    fi
}

# @desc Abstraction to install a package. Skips if already present.
# @arg $1 Package Name
System::install_pkg() {
    local pkg="$1"

    # macOS specific exception: 'feh' is not standard/needed for walls
    if [[ "$g_os_type" == "Darwin" && "$pkg" == "feh" ]]; then
        return
    fi

    if command -v "$pkg" &>/dev/null; then
        Logger::info "Package '$pkg' is already installed."
    else
        Logger::info "Installing package: $pkg..."
        # Execute the global install command constructed earlier
        $g_install_cmd "$pkg"
    fi
}


# ==============================================================================
# [MODULE] FILESYSTEM
# Helper methods for file operations, git cloning, and backups.
# ==============================================================================

# @desc Creates a temporary directory for download operations.
# @return Path to temp directory
FileSystem::make_temp_dir() {
    local temp_path="${TMPDIR:-/tmp/}$SCRIPT_NAME"
    mkdir -p "$temp_path"
    echo "$temp_path"
}

# @desc Clones a git repository, removing existing directory if conflict occurs.
# @arg $1 Repo URL
# @arg $2 Destination Path
FileSystem::git_clone() {
    local repo_url="$1"
    local dest="$2"

    if [[ -d "$dest" ]]; then
        Logger::warn "Directory '$dest' exists. Removing to ensure fresh clone..."
        rm -rf "$dest"
    fi
    git clone --quiet --depth=1 "$repo_url" "$dest"
}

# @desc Moves a file/folder to the global backup directory.
# @arg $1 Path to file/folder
FileSystem::backup_path() {
    local file_path="$1"
    if [[ -e "$file_path" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$file_path" "$BACKUP_DIR/"
        Logger::info "Backed up $(basename "$file_path") to $BACKUP_DIR"
    fi
}


# ==============================================================================
# [MODULE] INSTALLER
# Business logic for specific components (Grub, Nvim, Dotfiles, etc.)
# ==============================================================================

# @desc Installs Arch Linux via the Arch-I script (Linux only).
Installer::install_arch() {
    if [[ "$g_os_type" == "Darwin" ]]; then
        Logger::error "Arch-I installer is not supported on macOS."
        return
    fi

    Logger::info "Launching Arch-I installer..."
    local temp_dir
    temp_dir=$(FileSystem::make_temp_dir)

    curl -Lo "$temp_dir/arch_i.sh" https://bit.ly/Arch-I
    chmod +x "$temp_dir/arch_i.sh"
    "$temp_dir/arch_i.sh"
}

# @desc Installs LazyNV configuration for Neovim.
Installer::install_neovim() {
    local config_install_path="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
    local nvdot_repo_url="https://github.com/adityastomar67/NvDots-2.0.git"

    # 1. Dependency Check
    if ! command -v git >/dev/null 2>&1; then
        Logger::error "Git is not installed. Cannot install LazyNV."
        return 1
    fi

    Logger::info "Setting up Neovim (LazyNV)..."

    # 2. Backup existing configuration
    if [ -d "$config_install_path" ]; then
        FileSystem::backup_path "$config_install_path"
    fi

    # 3. Define stale cache/state directories to purge
    local neovim_state_paths=(
        "${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
        "${XDG_STATE_HOME:-$HOME/.local/state}/nvim"
        "${XDG_CACHE_HOME:-$HOME/.cache}/nvim"
    )

    # 4. Clean paths to prevent conflicts
    for path in "${neovim_state_paths[@]}"; do
        rm -rf "$path"
    done

    # 5. Clone the repository
    if FileSystem::git_clone "$nvdot_repo_url" "$config_install_path"; then
        Logger::success "NvDot installed. Launch 'nvim' to finish bootstrapping."
    else
        Logger::error "Failed to clone NvDot repository."
        return 1
    fi
}

# @desc Installs Dotfiles using manual symbolic links (ln -s).
Installer::install_dots() {
    Logger::info "Configuring Dotfiles..."

    # 1. Determine which repository to use based on OS
    local target_repo=""
    if [[ "$g_os_type" == "Darwin" ]]; then
        target_repo="$DOTS_URL_MAC"
        Logger::info "Detected macOS. Selected repo: $target_repo"
    else
        target_repo="$DOTS_URL_LINUX"
        Logger::info "Detected Linux. Selected repo: $target_repo"
    fi

    # 2. Clone the selected repository
    local dotfiles_dir="$HOME/.dotfiles"
    FileSystem::git_clone "$target_repo" "$dotfiles_dir"

    # 3. Manual Linking Loop (Replaces Stow)
    cd "$dotfiles_dir" || exit

    Logger::info "Creating symbolic links..."

    # Enable dotglob to catch hidden files (like .zshrc, .config)
    shopt -s dotglob

    for src in "$dotfiles_dir"/*; do
        local name
        name=$(basename "$src")

        # --- Filter Exclusions ---
        [[ "$name" == ".git" ]] && continue
        [[ "$name" == ".gitignore" ]] && continue
        [[ "$name" == ".DS_Store" ]] && continue
        [[ "$name" == "README.md" ]] && continue
        [[ "$name" == "LICENSE" ]] && continue
        [[ "$name" == "." || "$name" == ".." ]] && continue

        local target="$HOME/$name"

        # --- Handle Existing Files ---
        if [[ -e "$target" || -L "$target" ]]; then
            # Check if it's already a link pointing to the correct source (Idempotency)
            if [[ -L "$target" && "$(readlink "$target")" == "$src" ]]; then
                Logger::info "Skipping $name (Already linked)"
                continue
            fi

            Logger::warn "Target $target already exists. Backing up..."
            FileSystem::backup_path "$target"
        fi

        # --- Create Link ---
        # -s: Symbolic, -f: Force (remove existing destination if backup failed or logic allowed)
        ln -sf "$src" "$target"
        Logger::success "Linked: $name -> $target"
    done

    # Disable dotglob to reset shell behavior
    shopt -u dotglob

    Logger::success "Dotfiles installation complete."
}

# @desc Downloads wallpapers and sets one (Random or Chosen).
Installer::setup_wallpapers() {
    Logger::info "Configuring Wallpapers..."
    local wall_dir="$HOME/.config/wall"

    # 1. Install tool (Linux only)
    if [[ "$g_os_type" == "Linux" ]]; then
        System::install_pkg "feh"
    fi

    # 2. Download
    FileSystem::git_clone "$GITHUB_URL/Wallpapers.git" "$wall_dir"

    # 3. Flatten directory structure (Remove 'Static' folder if exists)
    if [[ -d "$wall_dir/Static" ]]; then
        mv "$wall_dir/Static/"* "$wall_dir/"
        rm -rf "$wall_dir/Static" "$wall_dir/.git" "$wall_dir/README.md"
    fi

    # 4. Normalize extensions (png -> jpg)
    # 'nullglob' ensures loop doesn't run if no pngs match
    shopt -s nullglob
    for img in "$wall_dir"/*.png; do
        mv "$img" "${img%.png}.jpg"
    done
    shopt -u nullglob

    # 5. User Selection
    echo "Select Wallpaper Mode:"
    local selected_file=""

    select mode in "Random" "Choose"; do
        case $mode in
            Random)
                local files=("$wall_dir"/*.jpg)
                # Select random index based on array length
                selected_file="${files[RANDOM % ${#files[@]}]}"
                Logger::success "Selected Random: $(basename "$selected_file")"
                break
                ;;
            Choose)
                # List files nicely for selection
                ls "$wall_dir"/*.jpg | xargs -n 1 basename
                read -r -p "Enter filename (e.g., wall1.jpg): " selection
                if [[ -f "$wall_dir/$selection" ]]; then
                    selected_file="$wall_dir/$selection"
                else
                    Logger::error "File '$selection' not found."
                fi
                break
                ;;
        esac
    done

    # 6. Apply Wallpaper
    if [[ -n "$selected_file" ]]; then
        if [[ "$g_os_type" == "Darwin" ]]; then
            # macOS: Use AppleScript to set desktop background
            osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$selected_file\""
            Logger::success "Wallpaper set via AppleScript."
        else
            # Linux: Use feh
            feh --no-fehbg --bg-fill "$selected_file"
            Logger::success "Wallpaper set via feh."
        fi
    fi
}

# @desc Installs GRUB Themes (Linux Only).
Installer::install_grub() {
    if [[ "$g_os_type" == "Darwin" ]]; then
        Logger::warn "GRUB is not supported on macOS."
        return
    fi

    # Verify we are on a system using GRUB
    if [[ ! -d "/boot/grub" ]]; then
        Logger::error "/boot/grub directory not found. Skipping GRUB setup."
        return
    fi

    Logger::info "Downloading GRUB Themes..."
    local tmp_grub="/tmp/GRUB_THEMES"
    mkdir -p "$tmp_grub"

    # Clone themes
    FileSystem::git_clone "https://github.com/AllJavi/tartarus-grub.git" "$tmp_grub/tartarus"
    sudo cp -r "$tmp_grub/tartarus/tartarus" /usr/share/grub/themes/

    FileSystem::git_clone "https://github.com/catppuccin/grub.git" "$tmp_grub/catppuccin"
    sudo cp -r "$tmp_grub/catppuccin/src/"* /usr/share/grub/themes/

    # User Selection
    echo "Select GRUB Theme:"
    local theme_name=""
    select theme in "catppuccin-latte" "catppuccin-frappe" "catppuccin-macchiato" "catppuccin-mocha" "tartarus"; do
        [ -n "$theme" ] && theme_name="$theme" && break
    done

    # Determine internal path structure based on theme choice
    local theme_conf_path
    if [[ "$theme_name" == "tartarus" ]]; then
        theme_conf_path="/usr/share/grub/themes/$theme_name/theme.txt"
    else
        theme_conf_path="/usr/share/grub/themes/$theme_name-grub-theme/theme.txt"
    fi

    Logger::info "Applying theme configuration..."
    # Update /etc/default/grub using sed
    sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME='$theme_conf_path'|" /etc/default/grub

    # Regenerate config
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    Logger::success "GRUB configuration updated."
}

# @desc Installs common system dependencies (Git, Curl, Node, Python tools).
Installer::install_dependencies() {
    Logger::info "Installing System Dependencies..."

    # 1. System Packages
    local basic_deps=("git" "curl" "wget" "neovim" "zsh" "tmux" "ripgrep" "fd" "fzf")
    for pkg in "${basic_deps[@]}"; do
        System::install_pkg "$pkg"
    done

    # 2. Node.js Packages (if npm exists)
    if command -v npm &>/dev/null; then
        Logger::info "Installing Node.js global packages..."
        local node_pkgs=("neovim" "tree-sitter-cli")
        for pkg in "${node_pkgs[@]}"; do
            # Use sudo for global install unless configured otherwise
            sudo npm i -g "$pkg"
        done
    else
        Logger::warn "NPM not found. Skipping Node dependencies."
    fi

    # 3. Python Packages (if python3 exists)
    if command -v python3 &>/dev/null; then
        Logger::info "Installing Python packages..."
        local py_pkgs=("pynvim")

        for pkg in "${py_pkgs[@]}"; do
            # Attempt install with --break-system-packages (for newer pip/Arch), fallback to standard
            if ! python3 -m pip install --user "$pkg" --break-system-packages 2>/dev/null; then
                python3 -m pip install --user "$pkg"
            fi
        done
    fi
}

# @desc Displays help menu
Installer::usage() {
    cat <<EOF
  ${BOLD}Usage:${RESET} ./$(basename "$0") [OPTIONS]

  ${BOLD}Options:${RESET}
    -a, --arch      Install Arch Linux (Linux Only).
    -d, --dots      Install dotfiles (stow).
    -g, --grub      Install GRUB Themes (Linux Only).
    -n, --nvim      Install LazyNV (Neovim Config).
    -r, --deps      Install standard dependencies.
    -w, --wall      Install and set Wallpapers.
    -z, --zsh       Install ZSH configuration.
    -h, --help      Show this help message.

  ${BOLD}Example:${RESET}
    ./fresh-install.sh --dots --nvim --wall
EOF
}


# ==============================================================================
# [MODULE] MAIN
# Entry point for the script execution.
# ==============================================================================
Main() {
    # Initialize Logger and System detection
    Logger::init
    Logger::header
    System::detect_os
    System::detect_pkg_manager

    # Ensure at least one argument is provided
    if [[ $# -eq 0 ]]; then
        Logger::warn "No arguments provided."
        Installer::usage
        exit 1
    fi

    # Parse Arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a|--arch)          Installer::install_arch ;;
            -d|--dots)          Installer::install_dots ;;
            -g|--grub)          Installer::install_grub ;;
            -n|--nvim|--LazyNV) Installer::install_neovim ;;
            -r|--deps)          Installer::install_dependencies ;;
            -w|--wall)          Installer::setup_wallpapers ;;
            -z|--zsh)
                Logger::info "Downloading and installing ZSH Config..."
                # Piping curl to bash for remote execution
                bash <(curl -s https://raw.githubusercontent.com/adityastomar67/zsh-conf/master/install.zsh)
                ;;
            -h|--help)          Installer::usage; exit 0 ;;
            *)
                Logger::error "Unknown option: $1"
                Installer::usage
                exit 1
                ;;
        esac
        shift
    done

    # Cleanup temporary files
    local temp_path="${TMPDIR:-/tmp/}$SCRIPT_NAME"
    if [[ -d "$temp_path" ]]; then
        rm -rf "$temp_path"
    fi

    Logger::success "Operation Complete. Enjoy your new setup!"
}

# Execute Main Function with all script arguments
Main "$@"
