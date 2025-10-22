#!/usr/bin/env bash

################################################################################
# Ubuntu Server Initial Setup Script
#
# Description: Interactive installation script for essential development tools
# Author: Generated for typhoon1217
# Date: 2025-01-22
#
# Features:
# - Interactive Y/N prompts for each component
# - Robust error handling with colored output
# - Automatic backups of existing configurations
# - Comprehensive logging
# - Docker user group setup
# - Zsh with prefix-based history search
# - Latest stable versions from official sources
################################################################################

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

################################################################################
# Global Variables
################################################################################

# Auto-yes mode flag
AUTO_YES=false

# Arrays to track installation status
declare -A BEFORE_INSTALL
declare -A AFTER_INSTALL

################################################################################
# Color Definitions & Logging Functions
################################################################################

# Only use colors if output is to a terminal
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    NC=''
fi

# Log file with timestamp
LOG_FILE="$HOME/ubuntu-setup-$(date +%Y%m%d-%H%M%S).log"
BACKUP_DIR="$HOME/.config-backups/$(date +%Y%m%d-%H%M%S)"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_header() {
    echo -e "\n${CYAN}========================================${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}$1${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}========================================${NC}\n" | tee -a "$LOG_FILE"
}

################################################################################
# Helper Functions
################################################################################

# Ask yes/no question with default
ask_yn() {
    local prompt="$1"
    local default="${2:-y}"
    local answer

    # If AUTO_YES mode is enabled, automatically return true
    if [ "$AUTO_YES" = true ]; then
        echo -e "${CYAN}${prompt} [AUTO-YES]${NC}" | tee -a "$LOG_FILE"
        return 0
    fi

    if [[ "$default" == "y" ]]; then
        prompt="${prompt} [Y/n]: "
    else
        prompt="${prompt} [y/N]: "
    fi

    read -rp "$(echo -e "${CYAN}${prompt}${NC}")" answer
    answer="${answer:-$default}"

    [[ "$answer" =~ ^[Yy]$ ]]
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Backup function
backup_path() {
    local path="$1"
    if [ -e "$path" ]; then
        mkdir -p "$BACKUP_DIR"
        local backup_name
        backup_name="$(basename "$path")-$(date +%H%M%S)"
        cp -r "$path" "$BACKUP_DIR/$backup_name"
        log_info "Backed up $path to $BACKUP_DIR/$backup_name"
    fi
}

# Check current installation status
check_installation_status() {
    log_header "Pre-Installation Status Check"

    log_info "Checking what is currently installed..."
    echo ""

    # Git
    if command_exists git; then
        BEFORE_INSTALL[git]="$(git --version 2>/dev/null || echo 'installed')"
        echo -e "  ${GREEN}✓${NC} git: ${BEFORE_INSTALL[git]}" | tee -a "$LOG_FILE"
    else
        BEFORE_INSTALL[git]="not installed"
        echo -e "  ${RED}✗${NC} git: not installed" | tee -a "$LOG_FILE"
    fi

    # Zsh
    if command_exists zsh; then
        BEFORE_INSTALL[zsh]="$(zsh --version 2>/dev/null || echo 'installed')"
        echo -e "  ${GREEN}✓${NC} zsh: ${BEFORE_INSTALL[zsh]}" | tee -a "$LOG_FILE"
    else
        BEFORE_INSTALL[zsh]="not installed"
        echo -e "  ${RED}✗${NC} zsh: not installed" | tee -a "$LOG_FILE"
    fi

    # Oh-my-zsh
    if [ -d "$HOME/.oh-my-zsh" ]; then
        BEFORE_INSTALL[oh-my-zsh]="installed"
        echo -e "  ${GREEN}✓${NC} oh-my-zsh: installed" | tee -a "$LOG_FILE"
    else
        BEFORE_INSTALL[oh-my-zsh]="not installed"
        echo -e "  ${RED}✗${NC} oh-my-zsh: not installed" | tee -a "$LOG_FILE"
    fi

    # Zoxide
    if command_exists zoxide; then
        BEFORE_INSTALL[zoxide]="$(zoxide --version 2>/dev/null || echo 'installed')"
        echo -e "  ${GREEN}✓${NC} zoxide: ${BEFORE_INSTALL[zoxide]}" | tee -a "$LOG_FILE"
    else
        BEFORE_INSTALL[zoxide]="not installed"
        echo -e "  ${RED}✗${NC} zoxide: not installed" | tee -a "$LOG_FILE"
    fi

    # Lazygit
    if command_exists lazygit; then
        BEFORE_INSTALL[lazygit]="$(lazygit --version 2>/dev/null | head -n1 || echo 'installed')"
        echo -e "  ${GREEN}✓${NC} lazygit: ${BEFORE_INSTALL[lazygit]}" | tee -a "$LOG_FILE"
    else
        BEFORE_INSTALL[lazygit]="not installed"
        echo -e "  ${RED}✗${NC} lazygit: not installed" | tee -a "$LOG_FILE"
    fi

    # Lazydocker
    if command_exists lazydocker; then
        BEFORE_INSTALL[lazydocker]="installed"
        echo -e "  ${GREEN}✓${NC} lazydocker: installed" | tee -a "$LOG_FILE"
    else
        BEFORE_INSTALL[lazydocker]="not installed"
        echo -e "  ${RED}✗${NC} lazydocker: not installed" | tee -a "$LOG_FILE"
    fi

    # Docker
    if command_exists docker; then
        BEFORE_INSTALL[docker]="$(docker --version 2>/dev/null || echo 'installed')"
        echo -e "  ${GREEN}✓${NC} docker: ${BEFORE_INSTALL[docker]}" | tee -a "$LOG_FILE"
    else
        BEFORE_INSTALL[docker]="not installed"
        echo -e "  ${RED}✗${NC} docker: not installed" | tee -a "$LOG_FILE"
    fi

    # Neovim
    if command_exists nvim; then
        BEFORE_INSTALL[nvim]="$(nvim --version 2>/dev/null | head -n1 || echo 'installed')"
        echo -e "  ${GREEN}✓${NC} neovim: ${BEFORE_INSTALL[nvim]}" | tee -a "$LOG_FILE"
    else
        BEFORE_INSTALL[nvim]="not installed"
        echo -e "  ${RED}✗${NC} neovim: not installed" | tee -a "$LOG_FILE"
    fi

    # UV
    if command_exists uv || [ -f "$HOME/.cargo/bin/uv" ]; then
        BEFORE_INSTALL[uv]="$(uv --version 2>/dev/null || echo 'installed')"
        echo -e "  ${GREEN}✓${NC} uv: ${BEFORE_INSTALL[uv]}" | tee -a "$LOG_FILE"
    else
        BEFORE_INSTALL[uv]="not installed"
        echo -e "  ${RED}✗${NC} uv: not installed" | tee -a "$LOG_FILE"
    fi

    # LuaRocks
    if command_exists luarocks; then
        BEFORE_INSTALL[luarocks]="$(luarocks --version 2>/dev/null | head -n1 || echo 'installed')"
        echo -e "  ${GREEN}✓${NC} luarocks: ${BEFORE_INSTALL[luarocks]}" | tee -a "$LOG_FILE"
    else
        BEFORE_INSTALL[luarocks]="not installed"
        echo -e "  ${RED}✗${NC} luarocks: not installed" | tee -a "$LOG_FILE"
    fi

    # Node.js
    if command_exists node; then
        BEFORE_INSTALL[node]="$(node --version 2>/dev/null || echo 'installed')"
        echo -e "  ${GREEN}✓${NC} node: ${BEFORE_INSTALL[node]}" | tee -a "$LOG_FILE"
    else
        BEFORE_INSTALL[node]="not installed"
        echo -e "  ${RED}✗${NC} node: not installed" | tee -a "$LOG_FILE"
    fi

    # GCC
    if command_exists gcc; then
        BEFORE_INSTALL[gcc]="$(gcc --version 2>/dev/null | head -n1 || echo 'installed')"
        echo -e "  ${GREEN}✓${NC} gcc: ${BEFORE_INSTALL[gcc]}" | tee -a "$LOG_FILE"
    else
        BEFORE_INSTALL[gcc]="not installed"
        echo -e "  ${RED}✗${NC} gcc: not installed" | tee -a "$LOG_FILE"
    fi

    # Btop
    if command_exists btop; then
        BEFORE_INSTALL[btop]="installed"
        echo -e "  ${GREEN}✓${NC} btop: installed" | tee -a "$LOG_FILE"
    else
        BEFORE_INSTALL[btop]="not installed"
        echo -e "  ${RED}✗${NC} btop: not installed" | tee -a "$LOG_FILE"
    fi

    # Tmux
    if command_exists tmux; then
        BEFORE_INSTALL[tmux]="$(tmux -V 2>/dev/null || echo 'installed')"
        echo -e "  ${GREEN}✓${NC} tmux: ${BEFORE_INSTALL[tmux]}" | tee -a "$LOG_FILE"
    else
        BEFORE_INSTALL[tmux]="not installed"
        echo -e "  ${RED}✗${NC} tmux: not installed" | tee -a "$LOG_FILE"
    fi

    # Fzf
    if command_exists fzf; then
        BEFORE_INSTALL[fzf]="$(fzf --version 2>/dev/null || echo 'installed')"
        echo -e "  ${GREEN}✓${NC} fzf: ${BEFORE_INSTALL[fzf]}" | tee -a "$LOG_FILE"
    else
        BEFORE_INSTALL[fzf]="not installed"
        echo -e "  ${RED}✗${NC} fzf: not installed" | tee -a "$LOG_FILE"
    fi

    # Ripgrep
    if command_exists rg; then
        BEFORE_INSTALL[ripgrep]="$(rg --version 2>/dev/null | head -n1 || echo 'installed')"
        echo -e "  ${GREEN}✓${NC} ripgrep: ${BEFORE_INSTALL[ripgrep]}" | tee -a "$LOG_FILE"
    else
        BEFORE_INSTALL[ripgrep]="not installed"
        echo -e "  ${RED}✗${NC} ripgrep: not installed" | tee -a "$LOG_FILE"
    fi

    # Fd
    if command_exists fd || command_exists fdfind; then
        BEFORE_INSTALL[fd]="installed"
        echo -e "  ${GREEN}✓${NC} fd: installed" | tee -a "$LOG_FILE"
    else
        BEFORE_INSTALL[fd]="not installed"
        echo -e "  ${RED}✗${NC} fd: not installed" | tee -a "$LOG_FILE"
    fi

    echo ""
    log_info "Status check complete"
}

################################################################################
# Prerequisites Check
################################################################################

check_prerequisites() {
    log_header "Checking Prerequisites"

    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        log_warn "⚠️  Running as root user detected!"
        log_warn "This is not recommended for security reasons."
        log_warn "Docker group setup will be skipped."
        echo ""
        if ! ask_yn "Continue anyway?" "n"; then
            log_error "Installation cancelled. Please run as normal user with sudo privileges."
            exit 1
        fi
        RUNNING_AS_ROOT=true
    else
        RUNNING_AS_ROOT=false

        # Check sudo access
        if ! sudo -n true 2>/dev/null; then
            log_info "This script requires sudo privileges. You may be prompted for your password."
            sudo -v || {
                log_error "Failed to obtain sudo privileges"
                exit 1
            }
        fi

        # Keep sudo alive
        while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    fi

    # Check for required commands
    for cmd in curl wget; do
        if ! command_exists "$cmd"; then
            log_warn "$cmd not found. Installing..."
            sudo apt-get update -y
            sudo apt-get install -y "$cmd"
        fi
    done

    # Check internet connectivity
    if ! ping -c 1 google.com >/dev/null 2>&1; then
        log_error "No internet connection detected"
        exit 1
    fi

    log_success "Prerequisites check passed"
}

################################################################################
# Installation Functions
################################################################################

install_system_updates() {
    log_header "System Updates"

    if ask_yn "Update system packages?" "y"; then
        log_info "Updating package lists..."
        sudo apt-get update -y

        log_info "Upgrading installed packages..."
        sudo apt-get upgrade -y

        log_info "Installing build essentials..."
        sudo apt-get install -y build-essential software-properties-common \
            apt-transport-https ca-certificates gnupg lsb-release

        log_success "System updated successfully"
        return 0
    else
        log_warn "Skipping system updates"
        return 1
    fi
}

install_git() {
    log_header "Git Installation"

    if command_exists git; then
        log_warn "Git is already installed ($(git --version))"
        if ! ask_yn "Reinstall/upgrade git?" "n"; then
            return 1
        fi
    fi

    if ask_yn "Install/upgrade git?" "y"; then
        sudo apt-get install -y git
        log_success "Git installed: $(git --version)"
        return 0
    else
        log_warn "Skipping git installation"
        return 1
    fi
}

install_zsh() {
    log_header "Zsh & Oh-My-Zsh Installation"

    if ask_yn "Install zsh with oh-my-zsh?" "y"; then
        # Install zsh
        if ! command_exists zsh; then
            log_info "Installing zsh..."
            sudo apt-get install -y zsh
        fi

        # Install oh-my-zsh
        if [ ! -d "$HOME/.oh-my-zsh" ]; then
            log_info "Installing oh-my-zsh..."
            RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
        else
            log_warn "oh-my-zsh already installed"
        fi

        # Install zsh-history-substring-search plugin
        local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search"
        if [ ! -d "$plugin_dir" ]; then
            log_info "Installing zsh-history-substring-search plugin..."
            git clone https://github.com/zsh-users/zsh-history-substring-search "$plugin_dir"
        fi

        log_success "Zsh installed successfully"
        return 0
    else
        log_warn "Skipping zsh installation"
        return 1
    fi
}

install_zoxide() {
    log_header "Zoxide Installation"

    if command_exists zoxide; then
        log_warn "Zoxide is already installed ($(zoxide --version))"
        if ! ask_yn "Reinstall zoxide?" "n"; then
            return 1
        fi
    fi

    if ask_yn "Install zoxide (smart cd command)?" "y"; then
        log_info "Installing zoxide..."

        # Install zoxide
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

        # Add to PATH temporarily for this session
        export PATH="$HOME/.local/bin:$PATH"

        # Create symlink to make it globally accessible
        if [ -f "$HOME/.local/bin/zoxide" ]; then
            if [ -w /usr/local/bin ] || [ "$EUID" -eq 0 ]; then
                ln -sf "$HOME/.local/bin/zoxide" /usr/local/bin/zoxide 2>/dev/null || true
                log_info "Created symlink: /usr/local/bin/zoxide"
            fi
        fi

        # Verify installation
        if command -v zoxide >/dev/null 2>&1 || [ -f "$HOME/.local/bin/zoxide" ]; then
            log_success "Zoxide installed successfully"
            if [ -f "$HOME/.local/bin/zoxide" ]; then
                log_info "Zoxide location: $HOME/.local/bin/zoxide"
            fi
            return 0
        else
            log_error "Zoxide installation failed"
            return 1
        fi
    else
        log_warn "Skipping zoxide installation"
        return 1
    fi
}

install_lazygit() {
    log_header "Lazygit Installation"

    if command_exists lazygit; then
        log_warn "Lazygit is already installed ($(lazygit --version))"
        if ! ask_yn "Reinstall lazygit?" "n"; then
            return 1
        fi
    fi

    if ask_yn "Install lazygit (terminal UI for git)?" "y"; then
        log_info "Installing lazygit from GitHub releases..."

        # Get latest release version
        local LAZYGIT_VERSION
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

        if [ -z "$LAZYGIT_VERSION" ]; then
            log_warn "Could not fetch latest version, using fallback version 0.43.1"
            LAZYGIT_VERSION="0.43.1"
        fi

        log_info "Installing lazygit version $LAZYGIT_VERSION..."

        # Create temp directory
        local temp_dir
        temp_dir=$(mktemp -d)
        cd "$temp_dir"

        # Download and install
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz
        sudo install lazygit /usr/local/bin

        cd - >/dev/null
        rm -rf "$temp_dir"

        log_success "Lazygit installed: $(lazygit --version)"
        return 0
    else
        log_warn "Skipping lazygit installation"
        return 1
    fi
}

install_lazydocker() {
    log_header "Lazydocker Installation"

    if command_exists lazydocker; then
        log_warn "Lazydocker is already installed"
        if ! ask_yn "Reinstall lazydocker?" "n"; then
            return 1
        fi
    fi

    if ask_yn "Install lazydocker (terminal UI for docker)?" "y"; then
        log_info "Installing lazydocker..."

        # Create temp directory
        local temp_dir
        temp_dir=$(mktemp -d)
        cd "$temp_dir"

        # Download and install
        curl -sS https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

        # Make globally accessible
        if [ -f "$HOME/.local/bin/lazydocker" ]; then
            sudo ln -sf "$HOME/.local/bin/lazydocker" /usr/local/bin/lazydocker
        fi

        cd - >/dev/null
        rm -rf "$temp_dir"

        log_success "Lazydocker installed successfully"
        return 0
    else
        log_warn "Skipping lazydocker installation"
        return 1
    fi
}

install_docker() {
    log_header "Docker CE Installation"

    if command_exists docker; then
        log_warn "Docker is already installed ($(docker --version))"
        if ! ask_yn "Reinstall docker?" "n"; then
            return 1
        fi
    fi

    if ask_yn "Install Docker CE (official repository)?" "y"; then
        log_info "Installing Docker CE..."

        # Remove old versions
        sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

        # Add Docker's official GPG key
        log_info "Adding Docker GPG key..."
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        # Add Docker repository
        log_info "Adding Docker repository..."
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Install Docker
        sudo apt-get update -y
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        # Add user to docker group (skip if running as root)
        if [ "$RUNNING_AS_ROOT" = false ]; then
            log_info "Adding user to docker group..."
            sudo usermod -aG docker "$USER"
            log_success "Docker installed successfully: $(docker --version)"
            log_warn "You need to log out and log back in for docker group changes to take effect"
            log_warn "Or run: newgrp docker"
        else
            log_success "Docker installed successfully: $(docker --version)"
            log_info "Running as root - docker group setup skipped (root has full access)"
        fi
        return 0
    else
        log_warn "Skipping docker installation"
        return 1
    fi
}

install_neovim() {
    log_header "Neovim Installation"

    if command_exists nvim; then
        log_warn "Neovim is already installed ($(nvim --version | head -n1))"
        if ! ask_yn "Reinstall neovim?" "n"; then
            return 1
        fi
    fi

    if ask_yn "Install Neovim (latest stable v0.10+)?" "y"; then
        log_info "Installing Neovim..."

        # Try to get the latest release tag from GitHub API
        log_info "Fetching latest Neovim release information..."
        NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

        if [ -z "$NVIM_VERSION" ]; then
            log_warn "Could not fetch latest version, using v0.10.0"
            NVIM_VERSION="v0.10.0"
        fi

        log_info "Latest version: $NVIM_VERSION"

        # Create directory for neovim
        sudo mkdir -p /opt/nvim

        # Download with proper versioned URL and fail-check
        log_info "Downloading Neovim AppImage ($NVIM_VERSION)..."
        NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim.appimage"

        if ! sudo curl -fL "$NVIM_URL" -o /opt/nvim/nvim.appimage; then
            log_error "Failed to download Neovim AppImage from GitHub"
            log_info "Trying alternative: installing from Ubuntu PPA..."

            # Fallback to PPA installation
            sudo add-apt-repository -y ppa:neovim-ppa/unstable
            sudo apt-get update
            sudo apt-get install -y neovim

            if command_exists nvim; then
                local version=$(nvim --version 2>/dev/null | head -n1)
                log_success "Neovim installed from PPA: $version"
                return 0
            else
                log_error "Neovim installation failed"
                return 1
            fi
        fi

        sudo chmod +x /opt/nvim/nvim.appimage

        # Extract AppImage (required for systems without FUSE)
        log_info "Extracting AppImage..."
        cd /opt/nvim
        if ! sudo ./nvim.appimage --appimage-extract >/dev/null 2>&1; then
            log_warn "AppImage extraction failed, trying to use AppImage directly..."
            cd - >/dev/null
            sudo rm -f /usr/local/bin/nvim
            sudo ln -sf /opt/nvim/nvim.appimage /usr/local/bin/nvim
        else
            cd - >/dev/null
            sudo rm -f /usr/local/bin/nvim

            # Create symlink - prefer extracted version
            if [ -f /opt/nvim/squashfs-root/usr/bin/nvim ]; then
                log_info "Creating symlink from extracted AppImage..."
                sudo ln -sf /opt/nvim/squashfs-root/usr/bin/nvim /usr/local/bin/nvim
            else
                log_warn "Extracted binary not found, using AppImage directly..."
                sudo ln -sf /opt/nvim/nvim.appimage /usr/local/bin/nvim
            fi
        fi

        # Verify installation
        if command_exists nvim; then
            local version=$(nvim --version 2>/dev/null | head -n1)
            log_success "Neovim installed: $version"

            # Check if it's v0.10+
            if nvim --version | head -n1 | grep -qE "v0\.([1-9][0-9]|10|11)" ; then
                log_info "✓ vim.uv API is available (Neovim 0.10+)"
            else
                log_warn "Neovim version might be older than 0.10"
            fi
            return 0
        else
            log_error "Neovim installation failed - command not found"
            log_info "Debug: checking what was created..."
            ls -la /opt/nvim/ 2>&1 | tee -a "$LOG_FILE"
            ls -la /usr/local/bin/nvim 2>&1 | tee -a "$LOG_FILE"
            return 1
        fi
    else
        log_warn "Skipping neovim installation"
        return 1
    fi
}

install_uv() {
    log_header "UV Installation (Python Package Manager)"

    if command_exists uv; then
        log_warn "UV is already installed ($(uv --version 2>/dev/null || echo 'installed'))"
        if ! ask_yn "Reinstall UV?" "n"; then
            return 1
        fi
    fi

    if ask_yn "Install UV (ultrafast Python package manager)?" "y"; then
        log_info "Installing UV..."

        # Install UV using the official installer
        curl -LsSf https://astral.sh/uv/install.sh | sh

        # Add to PATH temporarily for this session
        export PATH="$HOME/.cargo/bin:$PATH"

        # Create symlink to make it globally accessible
        if [ -f "$HOME/.cargo/bin/uv" ]; then
            if [ -w /usr/local/bin ] || [ "$EUID" -eq 0 ]; then
                ln -sf "$HOME/.cargo/bin/uv" /usr/local/bin/uv 2>/dev/null || true
                log_info "Created symlink: /usr/local/bin/uv"
            fi
        fi

        # Verify installation
        if command -v uv >/dev/null 2>&1 || [ -f "$HOME/.cargo/bin/uv" ]; then
            log_success "UV installed successfully"
            if command -v uv >/dev/null 2>&1; then
                log_info "UV version: $(uv --version)"
            else
                log_info "UV location: $HOME/.cargo/bin/uv"
            fi
            return 0
        else
            log_error "UV installation failed"
            return 1
        fi
    else
        log_warn "Skipping UV installation"
        return 1
    fi
}

install_luarocks() {
    log_header "LuaRocks Installation (Lua Package Manager)"

    if command_exists luarocks; then
        log_warn "LuaRocks is already installed ($(luarocks --version 2>/dev/null | head -n1 || echo 'installed'))"
        if ! ask_yn "Reinstall LuaRocks?" "n"; then
            return 1
        fi
    fi

    if ask_yn "Install LuaRocks (Lua package manager)?" "y"; then
        log_info "Installing LuaRocks..."

        # Install LuaRocks and dependencies
        sudo apt-get install -y luarocks lua5.4 liblua5.4-dev

        # Verify installation
        if command_exists luarocks; then
            local version=$(luarocks --version 2>/dev/null | head -n1)
            log_success "LuaRocks installed: $version"
            log_info "Lua version: $(lua -v 2>&1 | head -n1)"
            return 0
        else
            log_error "LuaRocks installation failed"
            return 1
        fi
    else
        log_warn "Skipping LuaRocks installation"
        return 1
    fi
}

install_nodejs() {
    log_header "Node.js Installation (Official LTS)"

    if command_exists node; then
        log_warn "Node.js is already installed ($(node --version 2>/dev/null || echo 'unknown'))"
        if ! ask_yn "Reinstall Node.js?" "n"; then
            return 1
        fi
    fi

    if ask_yn "Install Node.js LTS from official NodeSource repository?" "y"; then
        log_info "Installing Node.js LTS..."

        # Remove any existing nodejs packages (quote wildcards for zsh compatibility)
        sudo apt-get remove -y nodejs npm 2>/dev/null || true
        sudo apt-get purge -y 'libnode*' 'node-*' nodejs-doc 2>/dev/null || true
        sudo apt-get autoremove -y 2>/dev/null || true

        # Download and run NodeSource setup script for LTS (Node.js 20.x)
        log_info "Setting up NodeSource repository for Node.js 20.x LTS..."

        # The setup script may fail if broken PPAs exist, but still configure the repo
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - || log_warn "Setup script reported errors (possibly due to broken PPAs)"

        # Verify NodeSource repository was actually added
        if ls /etc/apt/sources.list.d/nodesource*.list 1> /dev/null 2>&1; then
            log_success "NodeSource repository file created"
        else
            log_error "NodeSource repository was not added"
            log_info "Manual fix: Remove broken PPAs with: sudo add-apt-repository --remove ppa:lazygit-team/release"
            return 1
        fi

        # Update package lists (suppress errors from broken PPAs)
        log_info "Updating package lists..."
        sudo apt-get update 2>&1 | grep -v "does not have a Release file" | grep -v "lazygit-team" || true

        # Install Node.js
        log_info "Installing Node.js and npm..."
        if sudo apt-get install -y nodejs; then
            # Verify we got the right version (should be v20.x or higher)
            if command_exists node; then
                local node_version=$(node --version 2>/dev/null)
                local major_version=$(echo "$node_version" | sed 's/v\([0-9]*\).*/\1/')

                if [ "$major_version" -ge 20 ]; then
                    local npm_version=$(npm --version 2>/dev/null)
                    log_success "Node.js installed: $node_version"
                    log_info "npm version: $npm_version"

                    # Install common global packages
                    if ask_yn "Install common global npm packages? (yarn, pnpm)" "y"; then
                        log_info "Installing yarn and pnpm..."
                        sudo npm install -g yarn pnpm
                        log_success "Global packages installed"
                    fi

                    return 0
                else
                    log_error "Wrong Node.js version installed: $node_version (expected v20.x+)"
                    log_warn "Ubuntu's apt repository was used instead of NodeSource"
                    log_info "This usually happens due to broken PPAs preventing repository setup"
                    log_info "Fix: sudo add-apt-repository --remove ppa:lazygit-team/release && re-run script"
                    return 1
                fi
            else
                log_error "Node.js command not found after installation"
                return 1
            fi
        else
            log_error "Failed to install Node.js package"
            return 1
        fi
    else
        log_warn "Skipping Node.js installation"
        return 1
    fi
}

install_gcc() {
    log_header "GCC & Build Tools Installation"

    if command_exists gcc; then
        log_warn "GCC is already installed ($(gcc --version | head -n1))"
        if ! ask_yn "Reinstall GCC and build tools?" "n"; then
            return 1
        fi
    fi

    if ask_yn "Install GCC and build tools (compiler, make, etc.)?" "y"; then
        log_info "Installing GCC and build essentials..."

        # Install build-essential package (includes gcc, g++, make)
        sudo apt-get install -y build-essential

        # Verify installation
        if command_exists gcc; then
            log_success "GCC installed successfully: $(gcc --version | head -n1)"
            log_info "Also installed: g++, make, and other build tools"
            return 0
        else
            log_error "GCC installation failed"
            return 1
        fi
    else
        log_warn "Skipping GCC installation"
        return 1
    fi
}

install_btop() {
    log_header "Btop Installation"

    if command_exists btop; then
        log_warn "Btop is already installed"
        if ! ask_yn "Reinstall btop?" "n"; then
            return 1
        fi
    fi

    if ask_yn "Install btop (modern system monitor)?" "y"; then
        log_info "Installing btop..."
        sudo apt-get install -y btop

        log_success "Btop installed successfully"
        return 0
    else
        log_warn "Skipping btop installation"
        return 1
    fi
}

install_tmux() {
    log_header "Tmux Installation"

    if command_exists tmux; then
        log_warn "Tmux is already installed ($(tmux -V))"
        if ! ask_yn "Reinstall tmux?" "n"; then
            return 1
        fi
    fi

    if ask_yn "Install tmux (terminal multiplexer)?" "y"; then
        log_info "Installing tmux..."
        sudo apt-get install -y tmux

        log_success "Tmux installed: $(tmux -V)"
        return 0
    else
        log_warn "Skipping tmux installation"
        return 1
    fi
}

install_fzf() {
    log_header "Fzf Installation"

    if command_exists fzf; then
        log_warn "Fzf is already installed ($(fzf --version))"
        if ! ask_yn "Reinstall fzf?" "n"; then
            return 1
        fi
    fi

    if ask_yn "Install fzf (fuzzy finder)?" "y"; then
        log_info "Installing fzf..."
        sudo apt-get install -y fzf

        log_success "Fzf installed: $(fzf --version)"
        return 0
    else
        log_warn "Skipping fzf installation"
        return 1
    fi
}

install_ripgrep_fd() {
    log_header "Ripgrep & Fd Installation"

    local installed=0

    if ask_yn "Install ripgrep & fd (modern grep/find alternatives)?" "y"; then
        if ! command_exists rg || ask_yn "Reinstall ripgrep?" "n"; then
            log_info "Installing ripgrep..."
            sudo apt-get install -y ripgrep
            installed=1
        fi

        if ! command_exists fd || ask_yn "Reinstall fd?" "n"; then
            log_info "Installing fd..."
            sudo apt-get install -y fd-find
            # Create symlink for fd
            sudo ln -sf "$(which fdfind)" /usr/local/bin/fd 2>/dev/null || true
            installed=1
        fi

        if [ $installed -eq 1 ]; then
            log_success "Ripgrep & fd installed successfully"
            return 0
        fi
    else
        log_warn "Skipping ripgrep & fd installation"
        return 1
    fi
}

################################################################################
# Post-Installation Configuration
################################################################################

configure_neovim() {
    log_header "Neovim Configuration"

    if ask_yn "Replace Neovim config with your custom config from GitHub?" "y"; then
        local nvim_config="$HOME/.config/nvim"

        # Backup existing config
        if [ -d "$nvim_config" ]; then
            backup_path "$nvim_config"
            log_info "Removing existing Neovim config..."
            rm -rf "$nvim_config"
        fi

        # Clone new config
        log_info "Cloning Neovim config from git@github.com:typhoon1217/nvimconfig.git..."

        if git clone git@github.com:typhoon1217/nvimconfig.git "$nvim_config" 2>/dev/null; then
            log_success "Neovim config installed successfully"
        else
            log_warn "Failed to clone via SSH. Trying HTTPS..."
            if git clone https://github.com/typhoon1217/nvimconfig.git "$nvim_config"; then
                log_success "Neovim config installed successfully (HTTPS)"
            else
                log_error "Failed to clone Neovim config"
                return 1
            fi
        fi
    else
        log_warn "Skipping Neovim configuration"
        return 1
    fi
}

configure_zsh() {
    log_header "Zsh Configuration"

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log_warn "oh-my-zsh not installed, skipping zsh configuration"
        return 1
    fi

    backup_path "$HOME/.zshrc"

    log_info "Configuring .zshrc..."

    # Create/update .zshrc
    cat > "$HOME/.zshrc" << 'EOF'
# Path additions (must be BEFORE oh-my-zsh to ensure tools are found)
export PATH="$HOME/.local/bin:$PATH"

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
    git
    docker
    zoxide
    fzf
    zsh-history-substring-search
)

source $ZSH/oh-my-zsh.sh

# Zoxide initialization
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
elif [ -f "$HOME/.local/bin/zoxide" ]; then
    eval "$($HOME/.local/bin/zoxide init zsh)"
fi

# Fzf key bindings and completion
if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
    source /usr/share/doc/fzf/examples/completion.zsh
fi

# History substring search key bindings (prefix-based search with arrows)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# History configuration
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# Aliases
alias vim='nvim'
alias vi='nvim'
alias lg='lazygit'
alias ld='lazydocker'
alias cat='batcat 2>/dev/null || cat'
EOF

    log_success "Zsh configured successfully"

    # Offer to change default shell
    if [ "$SHELL" != "$(which zsh)" ]; then
        if ask_yn "Set zsh as default shell?" "y"; then
            log_info "Changing default shell to zsh..."

            if [ "$RUNNING_AS_ROOT" = true ]; then
                # Running as root - change root's shell directly
                chsh -s "$(which zsh)" root
                log_success "Default shell changed to zsh for root user"
                log_warn "Start a new shell session with: exec zsh"
            else
                # Running as normal user
                sudo chsh -s "$(which zsh)" "$USER"
                log_success "Default shell changed to zsh"
                log_warn "You need to log out and log back in for shell change to take effect"
            fi
        fi
    else
        log_info "Zsh is already the default shell"
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    clear
    log_header "Ubuntu Server Initial Setup Script"

    log_info "This script will help you set up your Ubuntu server with development tools"
    if [ "$AUTO_YES" = true ]; then
        log_info "Running in AUTO-YES mode - all prompts will be automatically accepted"
    fi
    log_info "Log file: $LOG_FILE"
    log_info "Backup directory: $BACKUP_DIR"
    echo ""

    # Check current installation status
    check_installation_status

    if ! ask_yn "Continue with installation?" "y"; then
        log_warn "Installation cancelled by user"
        exit 0
    fi

    # Track installations
    declare -a installed_components
    declare -a already_installed
    declare -a newly_installed
    declare -a upgraded_components

    # Prerequisites
    check_prerequisites

    # System updates
    install_system_updates && installed_components+=("System Updates")

    # Core tools
    install_git && installed_components+=("Git")
    install_zsh && installed_components+=("Zsh + Oh-My-Zsh")
    install_zoxide && installed_components+=("Zoxide")
    install_lazygit && installed_components+=("Lazygit")
    install_lazydocker && installed_components+=("Lazydocker")
    install_docker && installed_components+=("Docker CE")
    install_neovim && installed_components+=("Neovim")
    install_luarocks && installed_components+=("LuaRocks")
    install_nodejs && installed_components+=("Node.js LTS")
    install_uv && installed_components+=("UV")
    install_gcc && installed_components+=("GCC & Build Tools")

    # Additional tools
    install_btop && installed_components+=("Btop")
    install_tmux && installed_components+=("Tmux")
    install_fzf && installed_components+=("Fzf")
    install_ripgrep_fd && installed_components+=("Ripgrep & Fd")

    # Post-installation configuration
    configure_neovim && installed_components+=("Neovim Config")
    configure_zsh && installed_components+=("Zsh Config")

    # Post-installation status check
    log_header "Post-Installation Status Check"

    # Check what was installed/upgraded
    for tool in git zsh oh-my-zsh zoxide lazygit lazydocker docker nvim luarocks node uv gcc btop tmux fzf ripgrep fd; do
        local current_status=""
        case $tool in
            git) command_exists git && current_status="$(git --version 2>/dev/null || echo 'installed')" ;;
            zsh) command_exists zsh && current_status="$(zsh --version 2>/dev/null || echo 'installed')" ;;
            oh-my-zsh) [ -d "$HOME/.oh-my-zsh" ] && current_status="installed" ;;
            zoxide) command_exists zoxide && current_status="$(zoxide --version 2>/dev/null || echo 'installed')" ;;
            lazygit) command_exists lazygit && current_status="$(lazygit --version 2>/dev/null | head -n1 || echo 'installed')" ;;
            lazydocker) command_exists lazydocker && current_status="installed" ;;
            docker) command_exists docker && current_status="$(docker --version 2>/dev/null || echo 'installed')" ;;
            nvim) command_exists nvim && current_status="$(nvim --version 2>/dev/null | head -n1 || echo 'installed')" ;;
            luarocks) command_exists luarocks && current_status="$(luarocks --version 2>/dev/null | head -n1 || echo 'installed')" ;;
            node) command_exists node && current_status="$(node --version 2>/dev/null || echo 'installed')" ;;
            uv) (command_exists uv || [ -f "$HOME/.cargo/bin/uv" ]) && current_status="$(uv --version 2>/dev/null || echo 'installed')" ;;
            gcc) command_exists gcc && current_status="$(gcc --version 2>/dev/null | head -n1 || echo 'installed')" ;;
            btop) command_exists btop && current_status="installed" ;;
            tmux) command_exists tmux && current_status="$(tmux -V 2>/dev/null || echo 'installed')" ;;
            fzf) command_exists fzf && current_status="$(fzf --version 2>/dev/null || echo 'installed')" ;;
            ripgrep) command_exists rg && current_status="$(rg --version 2>/dev/null | head -n1 || echo 'installed')" ;;
            fd) (command_exists fd || command_exists fdfind) && current_status="installed" ;;
        esac

        if [ -n "$current_status" ]; then
            AFTER_INSTALL[$tool]="$current_status"
        else
            AFTER_INSTALL[$tool]="not installed"
        fi
    done

    # Categorize installations (initialize arrays first)
    declare -a newly_installed_items=()
    declare -a already_installed_items=()
    declare -a upgraded_items=()

    for tool in "${!BEFORE_INSTALL[@]}"; do
        local before="${BEFORE_INSTALL[$tool]}"
        local after="${AFTER_INSTALL[$tool]:-not installed}"

        if [ "$before" = "not installed" ] && [ "$after" != "not installed" ]; then
            newly_installed_items+=("$tool: $after")
        elif [ "$before" != "not installed" ] && [ "$after" != "not installed" ] && [ "$before" != "$after" ]; then
            upgraded_items+=("$tool: $before → $after")
        elif [ "$before" != "not installed" ] && [ "$after" != "not installed" ]; then
            already_installed_items+=("$tool: $after")
        fi
    done

    # Summary
    log_header "Installation Summary"

    if [ ${#newly_installed_items[@]} -gt 0 ]; then
        echo -e "${GREEN}Newly Installed:${NC}" | tee -a "$LOG_FILE"
        for item in "${newly_installed_items[@]}"; do
            echo -e "  ${GREEN}✓${NC} $item" | tee -a "$LOG_FILE"
        done
        echo ""
    fi

    if [ ${#upgraded_items[@]} -gt 0 ]; then
        echo -e "${YELLOW}Upgraded:${NC}" | tee -a "$LOG_FILE"
        for item in "${upgraded_items[@]}"; do
            echo -e "  ${YELLOW}↑${NC} $item" | tee -a "$LOG_FILE"
        done
        echo ""
    fi

    if [ ${#already_installed_items[@]} -gt 0 ]; then
        echo -e "${BLUE}Already Installed (unchanged):${NC}" | tee -a "$LOG_FILE"
        for item in "${already_installed_items[@]}"; do
            echo -e "  ${BLUE}•${NC} $item" | tee -a "$LOG_FILE"
        done
        echo ""
    fi

    if [ ${#installed_components[@]} -eq 0 ]; then
        log_warn "No new components were installed or configured"
    else
        log_success "Actions performed during this run:"
        for component in "${installed_components[@]}"; do
            echo -e "  ${GREEN}✓${NC} $component" | tee -a "$LOG_FILE"
        done
    fi

    echo ""
    log_header "Next Steps"
    echo -e "${CYAN}1.${NC} Log out and log back in (or run: newgrp docker)" | tee -a "$LOG_FILE"
    echo -e "${CYAN}2.${NC} If you changed shell to zsh, restart your terminal" | tee -a "$LOG_FILE"
    echo -e "${CYAN}3.${NC} Test installations:" | tee -a "$LOG_FILE"
    echo -e "   ${BLUE}•${NC} docker --version && docker run hello-world" | tee -a "$LOG_FILE"
    echo -e "   ${BLUE}•${NC} nvim --version" | tee -a "$LOG_FILE"
    echo -e "   ${BLUE}•${NC} lazygit --version" | tee -a "$LOG_FILE"
    echo -e "   ${BLUE}•${NC} lazydocker --version" | tee -a "$LOG_FILE"
    echo -e "${CYAN}4.${NC} Backups are stored in: $BACKUP_DIR" | tee -a "$LOG_FILE"
    echo -e "${CYAN}5.${NC} Full log available at: $LOG_FILE" | tee -a "$LOG_FILE"

    echo ""
    log_success "Setup complete! Happy coding! 🚀"
}

# Error handler
trap 'log_error "Script failed at line $LINENO. Check $LOG_FILE for details."' ERR

# Parse command-line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -y|--yes)
                AUTO_YES=true
                shift
                ;;
            -h|--help)
                cat << EOF
Ubuntu Server Initial Setup Script

Usage: $0 [OPTIONS]

OPTIONS:
    -y, --yes       Auto-answer yes to all prompts (non-interactive mode)
    -h, --help      Display this help message

EXAMPLES:
    $0              # Interactive mode with prompts
    $0 -y           # Non-interactive mode, auto-yes to everything
    sudo bash $0 -y # Run with sudo in auto-yes mode

FEATURES:
    - Pre-installation status check
    - Interactive Y/N prompts for each component (or auto-yes with -y)
    - Installs: git, zsh, docker, neovim, lazygit, lazydocker, and more
    - Automatic backups before configuration changes
    - Detailed before/after installation summary
    - Comprehensive logging

For more information, see README.md

EOF
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use -h or --help for usage information"
                exit 1
                ;;
        esac
    done
}

# Parse arguments first
parse_args "$@"

# Run main function
main
