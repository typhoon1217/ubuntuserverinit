# Quick Start Guide

## One-Liner Setup

```bash
chmod +x ubuntu-server-setup.sh && ./ubuntu-server-setup.sh
```

## What You'll Be Asked

The script will prompt you for each component:

1. ✅ **System Updates** → Recommended: **Yes**
2. ✅ **Git** → Recommended: **Yes**
3. ✅ **Zsh + Oh-My-Zsh** → Recommended: **Yes**
4. ✅ **Zoxide** → Recommended: **Yes**
5. ✅ **Lazygit** → Recommended: **Yes**
6. ✅ **Lazydocker** → Recommended: **Yes**
7. ✅ **Docker CE** → Recommended: **Yes**
8. ✅ **Neovim** → Recommended: **Yes**
9. ⚡ **Btop** → Optional: **Yes/No**
10. ⚡ **Tmux** → Optional: **Yes/No**
11. ⚡ **Fzf** → Optional: **Yes/No**
12. ⚡ **Ripgrep & Fd** → Optional: **Yes/No**

## After Installation

### 1. Log Out & Back In

```bash
# This is REQUIRED for Docker group and shell changes
logout
# Or just close and reopen your terminal
```

### 2. Quick Test

```bash
# Test Docker
docker run hello-world

# Test Lazygit
lazygit --version

# Test Neovim
nvim --version

# Test Zoxide (smart cd)
z
```

## Key Features Configured

### 🔍 Prefix History Search
```bash
# Type a few letters and press UP arrow
do<UP>  # Shows only commands starting with "do"
git<UP> # Shows only git commands
```

### 📁 Smart Directory Navigation
```bash
# After visiting directories, jump to them by name
z documents    # Jumps to ~/Documents
z nvim         # Jumps to ~/.config/nvim
z proj         # Jumps to ~/projects
```

### 🔎 Fuzzy Search
```bash
# Press Ctrl+R to fuzzy search command history
<Ctrl-R>
# Type partial command, it finds matches
```

## Essential Commands

| Tool | Command | Purpose |
|------|---------|---------|
| Lazygit | `lg` or `lazygit` | Git terminal UI |
| Lazydocker | `ld` or `lazydocker` | Docker terminal UI |
| Neovim | `nvim` or `vim` or `vi` | Text editor |
| Zoxide | `z <name>` | Smart cd command |
| Btop | `btop` | System monitor |
| Tmux | `tmux` | Terminal multiplexer |
| Ripgrep | `rg <pattern>` | Fast grep |
| Fd | `fd <name>` | Fast find |

## Files Created

```
~/ubuntu-setup-YYYYMMDD-HHMMSS.log  # Installation log
~/.config-backups/                   # Config backups
~/.zshrc                             # Zsh configuration
~/.config/nvim/                      # Your Neovim config
```

## Rollback

If something goes wrong:

```bash
# View backups
ls ~/.config-backups/

# Restore Neovim config
cp -r ~/.config-backups/20250122-*/nvim-* ~/.config/nvim

# Restore Zsh config
cp ~/.config-backups/20250122-*/zshrc-* ~/.zshrc
```

## Troubleshooting

### Docker requires sudo?
```bash
# Refresh group membership
newgrp docker
# Or log out and back in
```

### Zsh not active?
```bash
# Check current shell
echo $SHELL
# Should show: /usr/bin/zsh

# If not, log out and back in
```

### History search not working?
```bash
# Reload zsh config
source ~/.zshrc
```

## Get Help

- Full documentation: See `README.md`
- Installation log: `cat ~/ubuntu-setup-*.log`
- Check installed tools: `which lazygit docker nvim`

---

**Need more details?** Read the full `README.md`
