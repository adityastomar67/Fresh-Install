#!/usr/bin/env bash
# ==============================================================================
#  SCRIPT: fresh-install.sh
#  AUTHOR: Aditya Singh Tomar (@adityastomar67)
#  DESC:   Advanced Cross-platform environment bootstrapper.
#          Features: Dry-run, Sudo Keep-alive, Logging, Spinners, Cleanup Traps.
#  LICENSE: MIT
# ==============================================================================

# --> STRICT MODE <--
# -e: Exit on error
# -u: Exit on unset variables
# -o pipefail: Fail on pipe errors
set -euo pipefail

# ==============================================================================
# [MODULE] PRE-FLIGHT CHECKS & COMPATIBILITY
# ==============================================================================

# Ensure we are running on a capable shell (Bash 4+ or Zsh)
if [ -n "${BASH_VERSION:-}" ] && [ "${BASH_VERSINFO[0]:-0}" -lt 4 ]; then
    if command -v zsh >/dev/null 2>&1; then
        echo " [INFO] Ancient Bash detected (macOS?). Restarting with Zsh..."
        # Pass all original arguments to the new shell
        exec zsh "$0" "$@"
    else
        echo " [ERROR] This script requires Bash 4.0+ or Zsh."
        exit 1
    fi
fi

# ==============================================================================
# [MODULE] CONFIGURATION & GLOBAL STATE
# ==============================================================================

declare -r SCRIPT_NAME="fresh-install"
declare -r LOG_FILE="${PWD}/install_$(date +%Y%m%d_%H%M%S).log"
declare -r GITHUB_URL="https://www.github.com/adityastomar67"

# --- Repositories ---
declare -r DOTS_URL_LINUX="$GITHUB_URL/.dotfiles.git"
declare -r DOTS_URL_MAC="$GITHUB_URL/.dotfiles-mac.git"
declare -r NVDOTS_REPO_URL="https://github.com/adityastomar67/NvDots-2.0.git"
declare -r WALLPAPER_REPO_URL="$GITHUB_URL/Wallpapers.git"

declare -r BACKUP_DIR="$HOME/.config/backup_$(date +%s)"

# --- Global Flags ---
declare g_os_type=""
declare g_os_distro=""
declare -a g_install_cmd=()
declare g_dry_run=0

# ==============================================================================
# [MODULE] LOGGER & UTILITIES
# ==============================================================================

# 1. PRE-DECLARE GLOBAL COLOR VARIABLES
# This prevents 'parameter not set' errors in strict mode (-u)
# and ensures variable persistence in Zsh.
BOLD="" RESET="" RED="" GREEN="" BLUE="" YELLOW="" GREY=""

# Setup cleanup trap for exit/interrupt
cleanup() {
    local exit_code=$?

    # Restore cursor visibility if script died during a spinner
    if command -v tput >/dev/null; then tput cnorm; fi

    # Stop the sudo keep-alive background loop
    if [[ -n "${SUDO_PID:-}" ]]; then kill "$SUDO_PID" 2>/dev/null || true; fi

    # Remove temp dir
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then rm -rf "$TEMP_DIR"; fi

    if [ $exit_code -ne 0 ]; then
        echo -e "\n\033[0;31m[FAILURE] Script finished with errors. Check $LOG_FILE\033[0m"
    fi
    exit "$exit_code"
}
trap cleanup EXIT INT TERM

Logger::init() {
    # Check if terminal supports colors
    if [ -t 1 ] && command -v tput >/dev/null; then
        local ncolors
        ncolors=$(tput colors 2>/dev/null || echo 0)

        if [ "$ncolors" -ge 8 ]; then
            BOLD=$(tput bold)
            RESET=$(tput sgr0)
            RED=$(tput setaf 1)
            GREEN=$(tput setaf 76)
            BLUE=$(tput setaf 38)
            YELLOW=$(tput setaf 3)
            GREY=$(tput setaf 240)
        fi
    fi

    echo "--- Execution Started: $(date) ---" > "$LOG_FILE"
}

Logger::log() {
    local type="$1"
    local msg="$2"
    local color="$3"
    local timestamp
    timestamp=$(date "+%H:%M:%S")

    # Console Output
    echo -e "${GREY}[$timestamp]${RESET} ${color}[$type]${RESET} $msg"
    # Log File Output (Strip ANSI codes)
    echo "[$timestamp] [$type] $msg" | sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE"
}

Logger::info()    { Logger::log "INFO"    "$1" "$BLUE"; }
Logger::success() { Logger::log "SUCCESS" "$1" "$GREEN"; }
Logger::warn()    { Logger::log "WARN"    "$1" "$YELLOW"; }
Logger::error()   { Logger::log "ERROR"   "$1" "$RED" >&2; }
Logger::dry()     { Logger::log "DRY-RUN" "$1" "$YELLOW"; }

# ASCII Spinner for long running tasks
Util::spinner() {
    local label="$1"
    shift
    local pid

    if [[ $g_dry_run -eq 1 ]]; then
        Logger::dry "Would execute: $*"
        return 0
    fi

    # Run command in background, redirect all output to log
    "$@" >> "$LOG_FILE" 2>&1 &
    pid=$!

    local delay=0.1
    local spinstr='|/-\'

    # Hide Cursor
    tput civis 2>/dev/null

    echo -ne "${GREY}[WAIT]${RESET} ${BLUE}$label...${RESET} "
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done

    wait "$pid"
    local exit_code=$?

    # Restore Cursor
    tput cnorm 2>/dev/null

    if [ $exit_code -eq 0 ]; then
        printf "${GREEN}DONE${RESET}\n"
    else
        printf "${RED}FAIL${RESET}\n"
        Logger::error "Command failed. Check log for details."
        return $exit_code
    fi
}

# Keep Sudo alive in background
Util::sudo_refresh() {
    sudo -v
    ( while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null ) &
    SUDO_PID=$!
}

Logger::header() {
    clear
    cat <<EOF
${BLUE}
 _____  ____     ___  _____ __ __        ____  ____   _____ ______   ____  _      _
|     ||    \   /  _]/ ___/|  |  |      |    ||    \ / ___/|      | /    || |    | |
|   __||  D  ) /  [_(   \_ |  |  | _____ |  | |  _  (   \_ |      ||  o  || |    | |
|  |_  |    / |    _]\__  ||  _  ||     ||  | |  |  |\__  ||_|  |_||     || |___ | |___
|   _] |    \ |   [_ /  \ ||  |  ||_____||  | |  |  |/  \ |  |  |  |  _  ||     ||     |
|  |   |  .  \|     |\    ||  |  |       |  | |  |  |\    |  |  |  |  |  ||     ||     |
|__|   |__|\_||_____| \___||__|__|      |____||__|__| \___|  |__|  |__|__||_____||_____|
                                                                                        
${RESET}
   ${BOLD}:: Advanced Dotfiles Bootstrapper ::${RESET}
   ${GREY}Log File: $LOG_FILE${RESET}
EOF
    echo
}

# ==============================================================================
# [MODULE] SYSTEM ABSTRACTION
# ==============================================================================

System::detect_os() {
    g_os_type=$(uname -s)

    if [[ "$g_os_type" == "Linux" ]]; then
        if [ -f /etc/os-release ]; then
            # Source os-release to get ID
            . /etc/os-release
            g_os_distro=$ID
        else
            g_os_distro="unknown"
        fi
    elif [[ "$g_os_type" == "Darwin" ]]; then
        g_os_distro="macos"
    fi

    Logger::info "Detected OS: $g_os_type ($g_os_distro)"
}

System::detect_pkg_manager() {
    if [[ "$g_os_type" == "Darwin" ]]; then
        if ! command -v brew &>/dev/null; then
            Logger::info "Homebrew not found. Installing..."
            if [[ $g_dry_run -eq 0 ]]; then
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
        fi
        g_install_cmd=(brew install)

    elif [[ "$g_os_type" == "Linux" ]]; then
        case "$g_os_distro" in
            arch|manjaro|endeavouros)
                g_install_cmd=(sudo pacman -Sy --noconfirm --needed) ;;
            debian|ubuntu|pop|kali|linuxmint)
                g_install_cmd=(sudo apt-get install -y) ;;
            fedora|rhel|centos)
                g_install_cmd=(sudo dnf install -y) ;;
            *)
                Logger::error "Unsupported Distribution: $g_os_distro"
                exit 1 ;;
        esac
    fi
}

System::install_pkg() {
    local pkg="$1"
    # macOS exception: feh not needed
    if [[ "$g_os_type" == "Darwin" && "$pkg" == "feh" ]]; then return; fi

    if command -v "$pkg" &>/dev/null; then
        Logger::info "Package '$pkg' already installed."
    else
        Util::spinner "Installing $pkg" "${g_install_cmd[@]}" "$pkg"
    fi
}

# ==============================================================================
# [MODULE] FILESYSTEM & GIT
# ==============================================================================

FileSystem::make_temp_dir() {
    TEMP_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t "$SCRIPT_NAME")
    echo "$TEMP_DIR"
}

FileSystem::git_clone() {
    local repo_url="$1"
    local dest="$2"

    if [[ -d "$dest" ]]; then
        Logger::warn "Directory '$dest' exists. Resetting..."
        if [[ $g_dry_run -eq 0 ]]; then
            rm -rf "$dest"
        else
            Logger::dry "Would remove $dest"
        fi
    fi

    Util::spinner "Cloning $(basename "$repo_url")" git clone --quiet --depth=1 "$repo_url" "$dest"
}

FileSystem::backup_path() {
    local file_path="$1"
    if [[ -e "$file_path" || -L "$file_path" ]]; then
        if [[ $g_dry_run -eq 0 ]]; then
            mkdir -p "$BACKUP_DIR"
            mv "$file_path" "$BACKUP_DIR/"
        fi
        Logger::info "Backed up $(basename "$file_path") to $BACKUP_DIR"
    fi
}

Helper::set_globbing() {
    local state="$1"
    if [ -n "${BASH_VERSION:-}" ]; then
        if [[ "$state" == "on" ]]; then shopt -s dotglob nullglob; else shopt -u dotglob nullglob; fi
    elif [ -n "${ZSH_VERSION:-}" ]; then
        if [[ "$state" == "on" ]]; then setopt glob_dots null_glob; else unsetopt glob_dots null_glob; fi
    fi
}

# ==============================================================================
# [MODULE] INSTALLERS
# ==============================================================================

Installer::install_neovim() {
    local config_path="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

    Logger::info "Preparing Neovim (NvDots)..."

    # Define paths to purge
    local nvim_data=(
        "$config_path"
        "${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
        "${XDG_STATE_HOME:-$HOME/.local/state}/nvim"
        "${XDG_CACHE_HOME:-$HOME/.cache}/nvim"
    )

    for path in "${nvim_data[@]}"; do
        FileSystem::backup_path "$path"
        if [[ $g_dry_run -eq 0 ]]; then rm -rf "$path"; fi
    done

    FileSystem::git_clone "$NVDOTS_REPO_URL" "$config_path"
    Logger::success "Neovim setup complete. Run 'nvim' to initialize Lazy."
}

Installer::install_dots() {
    Logger::info "Setting up Dotfiles..."

    local target_repo=""
    [[ "$g_os_type" == "Darwin" ]] && target_repo="$DOTS_URL_MAC" || target_repo="$DOTS_URL_LINUX"

    local dotfiles_dir="$HOME/.dotfiles"
    FileSystem::git_clone "$target_repo" "$dotfiles_dir"

    # If dry run, we can't cd into a dir that doesn't exist
    if [[ $g_dry_run -eq 1 ]]; then
        Logger::dry "Would link files from $dotfiles_dir to $HOME"
        return
    fi

    cd "$dotfiles_dir" || exit
    Helper::set_globbing "on"

    for src in "$dotfiles_dir"/*; do
        local name
        name=$(basename "$src")
        # Exclude metadata files
        [[ "$name" =~ ^(\.git|\.gitignore|\.DS_Store|README\.md|LICENSE|\.|\.\.)$ ]] && continue

        local target="$HOME/$name"

        # Check for existing symlink pointing to correct location
        if [[ -L "$target" && "$(readlink "$target")" == "$src" ]]; then
            Logger::info "Skipping $name (Correctly Linked)"
            continue
        fi

        FileSystem::backup_path "$target"

        ln -sf "$src" "$target"
        Logger::success "Linked: $name -> $target"
    done
    Helper::set_globbing "off"
}

Installer::setup_wallpapers() {
    local wall_dir="$HOME/.config/wall"

    if [[ "$g_os_type" == "Linux" ]]; then System::install_pkg "feh"; fi
    FileSystem::git_clone "$WALLPAPER_REPO_URL" "$wall_dir"

    # Cleanup Static dir if exists (specific to repo structure)
    if [[ $g_dry_run -eq 0 && -d "$wall_dir/Static" ]]; then
        mv "$wall_dir/Static/"* "$wall_dir/" 2>/dev/null || true
        rm -rf "$wall_dir/Static" "$wall_dir/.git" "$wall_dir/README.md"

        # Convert png to jpg ext for consistent globbing
        Helper::set_globbing "on"
        for img in "$wall_dir"/*.png; do
            [ -f "$img" ] && mv "$img" "${img%.png}.jpg"
        done
        Helper::set_globbing "off"
    fi

    if [[ $g_dry_run -eq 1 ]]; then Logger::dry "Would set wallpaper"; return; fi

    local selected_file=""
    local jpg_files=("$wall_dir"/*.jpg)

    if [[ ${#jpg_files[@]} -eq 0 ]]; then
        Logger::warn "No wallpapers found in $wall_dir"
        return
    fi

    # Auto-select random
    selected_file=$(printf "%s\n" "${jpg_files[@]}" | shuf -n 1)
    Logger::info "Selected Random Wallpaper: $(basename "$selected_file")"

    if [[ "$g_os_type" == "Darwin" ]]; then
        osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$selected_file\""
    else
        feh --no-fehbg --bg-fill "$selected_file"
    fi
}

Installer::install_grub() {
    [[ "$g_os_type" == "Darwin" ]] && return
    [[ ! -d "/boot/grub" ]] && { Logger::error "No GRUB found."; return; }

    local tmp_grub
    tmp_grub=$(FileSystem::make_temp_dir)

    Util::spinner "Downloading GRUB Themes" git clone --quiet https://github.com/vinceliuice/grub2-themes.git "$tmp_grub/tela"

    if [[ $g_dry_run -eq 0 ]]; then
        Logger::info "Installing Tela GRUB Theme..."
        sudo "$tmp_grub/tela/install.sh" -b -t tela
    else
        Logger::dry "Would run sudo install.sh for GRUB"
    fi
}

Installer::install_dependencies() {
    local basic_deps=("git" "curl" "wget" "neovim" "zsh" "tmux" "ripgrep" "fd" "fzf")

    for pkg in "${basic_deps[@]}"; do
        System::install_pkg "$pkg"
    done

    # Language specific managers
    if command -v npm &>/dev/null; then
        Logger::info "Installing Node globals..."
        if [[ $g_dry_run -eq 0 ]]; then
            sudo npm i -g neovim tree-sitter-cli >/dev/null 2>&1
        fi
    fi
}

# ==============================================================================
# [MODULE] MAIN EXECUTION
# ==============================================================================

Main() {
    Logger::init
    Logger::header

    # Parse Arguments
    local install_arch=0
    local install_dots=0
    local install_nvim=0
    local install_deps=0
    local install_wall=0
    local install_grub=0
    local install_zsh=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)      g_dry_run=1; Logger::warn "DRY RUN MODE ACTIVE" ;;
            -a|--arch)      install_arch=1 ;;
            -d|--dots)      install_dots=1 ;;
            -g|--grub)      install_grub=1 ;;
            -n|--nvim)      install_nvim=1 ;;
            -r|--deps)      install_deps=1 ;;
            -w|--wall)      install_wall=1 ;;
            -z|--zsh)       install_zsh=1 ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo "  --dry-run   Simulate actions without changes"
                echo "  -d, --dots  Install Dotfiles"
                echo "  -n, --nvim  Install Neovim Config"
                echo "  -w, --wall  Install Wallpapers"
                echo "  -r, --deps  Install Dependencies"
                exit 0 ;;
            *) Logger::error "Unknown option: $1"; exit 1 ;;
        esac
        shift
    done

    # Require sudo upfront if we are doing system things
    if [[ $install_deps -eq 1 || $install_grub -eq 1 ]]; then
        Logger::info "Requesting administrative privileges..."
        Util::sudo_refresh
    fi

    System::detect_os
    System::detect_pkg_manager

    # Execute phases
    [[ $install_arch -eq 1 ]] && {
        if [[ "$g_os_type" == "Linux" ]]; then
            curl -Lo /tmp/arch_i.sh https://bit.ly/Arch-I && bash /tmp/arch_i.sh
        else
            Logger::error "Arch install not supported on macOS"
        fi
    }

    [[ $install_deps -eq 1 ]] && Installer::install_dependencies

    # FIX: Use 'zsh' here instead of 'bash'
    [[ $install_zsh -eq 1 ]]  && {
        Logger::info "Installing ZSH..."
        if command -v zsh >/dev/null; then
            zsh <(curl -s https://raw.githubusercontent.com/adityastomar67/zsh-conf/master/install.zsh)
        else
            Logger::error "Zsh not found. Cannot install Zsh config."
        fi
    }

    [[ $install_dots -eq 1 ]] && Installer::install_dots
    [[ $install_nvim -eq 1 ]] && Installer::install_neovim
    [[ $install_wall -eq 1 ]] && Installer::setup_wallpapers
    [[ $install_grub -eq 1 ]] && Installer::install_grub

    Logger::success "All requested tasks completed."
    echo -e "${GREY}Log saved to: $LOG_FILE${RESET}"
}

Main "$@"
