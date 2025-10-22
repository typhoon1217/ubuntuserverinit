# Ubuntu Server Initial Setup Script

A comprehensive, interactive setup script for Ubuntu servers with essential development tools.

## Features

✨ **Interactive Installation** - Y/N prompts for each component
🎨 **Colorized Output** - Clear, readable feedback with severity levels
🔒 **Robust Error Handling** - Strict error checking with detailed logging
💾 **Automatic Backups** - Saves existing configurations before modification
📊 **Comprehensive Logging** - Full logs saved with timestamps
🐳 **Docker User Setup** - Automatic user group configuration
🐚 **Smart Shell Config** - Zsh with prefix-based history search

## What Gets Installed

### Core Tools
- **git** - Version control system
- **zsh + oh-my-zsh** - Enhanced shell with framework
- **zoxide** - Smart cd command (remembers directories)
- **lazygit** - Terminal UI for git
- **lazydocker** - Terminal UI for Docker
- **Docker CE** - Latest Docker from official repository
- **Neovim** - Latest stable from PPA

### Additional Tools
- **btop** - Modern system resource monitor
- **tmux** - Terminal multiplexer
- **fzf** - Fuzzy finder for files and history
- **ripgrep** - Fast grep alternative
- **fd** - Fast find alternative

## Usage

### Basic Usage

```bash
./ubuntu-server-setup.sh
```

The script will:
1. Check prerequisites (sudo access, internet connection)
2. Present Y/N prompts for each component
3. Install selected components with progress feedback
4. Configure post-installation settings
5. Display summary report with next steps

### What to Expect

```
========================================
Ubuntu Server Initial Setup Script
========================================

[INFO] This script will help you set up your Ubuntu server
[INFO] Log file: ~/ubuntu-setup-20250122-143022.log

Continue with installation? [Y/n]: y

========================================
System Updates
========================================
Update system packages? [Y/n]: y
[INFO] Updating package lists...
[SUCCESS] System updated successfully

========================================
Git Installation
========================================
Install/upgrade git? [Y/n]: y
[SUCCESS] Git installed: git version 2.43.0

...
```

## Post-Installation

### Important Steps

1. **Log out and back in** (required for Docker group and shell changes)
   ```bash
   # Or refresh Docker group immediately:
   newgrp docker
   ```

2. **Test installations:**
   ```bash
   docker --version
   docker run hello-world
   nvim --version
   lazygit --version
   lazydocker --version
   ```

3. **Check your shell:**
   ```bash
   echo $SHELL
   # Should show: /usr/bin/zsh
   ```

### Zsh Features

The configured zsh includes:

- **Prefix-based history search**: Type `do` and press ↑ to see only commands starting with `do`
- **Oh-my-zsh plugins**: git, docker, zoxide, fzf, history-substring-search
- **Smart directory navigation**: Use `z <partial-name>` to jump to frequently used directories
- **Fuzzy search**: Press `Ctrl+R` for fuzzy command history search

### Aliases

The following aliases are configured in `.zshrc`:

```bash
vim='nvim'    # Use Neovim instead of Vim
vi='nvim'     # Use Neovim instead of Vi
lg='lazygit'  # Quick access to lazygit
ld='lazydocker'  # Quick access to lazydocker
```

## Configuration Files

### Locations

- **Log file**: `~/ubuntu-setup-YYYYMMDD-HHMMSS.log`
- **Backups**: `~/.config-backups/YYYYMMDD-HHMMSS/`
- **Zsh config**: `~/.zshrc`
- **Neovim config**: `~/.config/nvim/`

### Neovim Configuration

The script clones your custom Neovim configuration from:
- Primary: `git@github.com:typhoon1217/nvimconfig.git` (SSH)
- Fallback: `https://github.com/typhoon1217/nvimconfig.git` (HTTPS)

**Note**: SSH requires GitHub SSH key setup. If SSH fails, HTTPS is attempted automatically.

## Security Considerations

### Docker Group

⚠️ **Important**: Members of the `docker` group have root-level privileges on the host system.

- Only add trusted users to the docker group
- Consider using Docker rootless mode for production environments
- Read more: https://docs.docker.com/engine/security/rootless/

### Backups

All existing configurations are backed up to `~/.config-backups/` before modification:

```bash
# View backups
ls -la ~/.config-backups/

# Restore a backup
cp -r ~/.config-backups/20250122-143022/nvim-143500 ~/.config/nvim
```

## Troubleshooting

### Common Issues

**Issue**: Script fails with "permission denied"
```bash
# Solution: Make script executable
chmod +x ubuntu-server-setup.sh
```

**Issue**: Docker commands require sudo
```bash
# Solution: Log out and back in, or run:
newgrp docker
```

**Issue**: Neovim config clone fails
```bash
# Solution: Setup SSH key for GitHub
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub
# Add the public key to GitHub: Settings → SSH keys
```

**Issue**: Zsh not activated
```bash
# Solution: Check default shell
echo $SHELL

# If not zsh, change manually:
chsh -s $(which zsh)
# Then log out and back in
```

**Issue**: History search not working with arrows
```bash
# Solution: Check plugin installation
ls ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search

# If missing, clone manually:
git clone https://github.com/zsh-users/zsh-history-substring-search \
  ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search
```

### Check Installation

```bash
# View detailed log
cat ~/ubuntu-setup-*.log

# Check specific tool
which lazygit
lazygit --version

# Verify Docker group
groups
# Should include 'docker'

# Test Docker without sudo
docker ps
```

## Customization

### Modify Components

Edit the script to skip or add components:

```bash
# Comment out unwanted installations in main() function
# install_btop && installed_components+=("Btop")  # Disabled
```

### Change Zsh Theme

Edit `~/.zshrc`:

```bash
# Change from robbyrussell to another theme
ZSH_THEME="agnoster"  # or "powerlevel10k", "spaceship", etc.
```

### Add More Plugins

Edit `~/.zshrc`:

```bash
plugins=(
    git
    docker
    zoxide
    fzf
    zsh-history-substring-search
    # Add more plugins here
    kubectl
    terraform
    aws
)
```

## Requirements

- Ubuntu 20.04, 22.04, or 24.04
- Sudo privileges
- Internet connection
- ~500MB disk space for all tools

## Best Practices Applied

This script follows industry best practices:

✅ Strict error handling (`set -euo pipefail`)
✅ Color codes only for terminal output
✅ Comprehensive logging to file
✅ Backup before modification
✅ Official package sources (PPAs, repos)
✅ User permission validation
✅ Internet connectivity check
✅ Idempotent operations (safe to re-run)

## References

- [Docker Official Docs](https://docs.docker.com/engine/install/ubuntu/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Neovim](https://neovim.io/)
- [Lazygit](https://github.com/jesseduffield/lazygit)
- [Lazydocker](https://github.com/jesseduffield/lazydocker)
- [Zoxide](https://github.com/ajeetdsouza/zoxide)

## License

This script is provided as-is for personal use.

---

**Generated for**: typhoon1217
**Date**: 2025-01-22
**Version**: 1.0.0
