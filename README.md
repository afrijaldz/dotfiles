# dotfiles

Personal dotfiles for macOS and Linux (WSL/Ubuntu). Consistent development environment across all machines.

## What's included

| Component | Config | Notes |
|-----------|--------|-------|
| **Shell** | `.zshrc`, `.zshenv`, `.p10k.zsh` | Zsh + oh-my-zsh + Powerlevel10k |
| **Editor** | `.config/nvim/` | Neovim with LazyVim |
| **Terminal** | `.config/tmux/tmux.conf` | Tmux with Ctrl+A prefix, vim-style navigation, TPM |
| **Prompt** | `.p10k.zsh` | Powerlevel10k (configure per-machine with `p10k configure`) |

## Quick start

```bash
# Clone the repo
git clone git@github.com:afrijaldz/dotfiles.git ~/dotfiles

# Run the bootstrap script (installs everything + symlinks configs)
cd ~/dotfiles && ./bootstrap.sh
```

The bootstrap script handles:
- Installing zsh (if missing) and setting it as the default shell
- Installing oh-my-zsh, Powerlevel10k, zsh plugins
- Installing TPM (Tmux Plugin Manager)
- Symlinking all config files (backs up existing ones first)

## Manual setup

If you prefer to do things step by step:

```bash
# 1. Clone
git clone git@github.com:afrijaldz/dotfiles.git ~/dotfiles && cd ~/dotfiles

# 2. Symlink configs
ln -sf ~/dotfiles/.zshrc    ~/.zshrc
ln -sf ~/dotfiles/.zshenv   ~/.zshenv
ln -sf ~/dotfiles/.p10k.zsh ~/.p10k.zsh
ln -sf ~/dotfiles/.config/tmux ~/.config/tmux
ln -sf ~/dotfiles/.config/nvim ~/.config/nvim

# 3. Install oh-my-zsh (if not installed)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 4. Install TPM
git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## First-time setup per platform

### macOS
Most tools are already available via Homebrew. Bootstrap should work out of the box.

### WSL / Ubuntu
```bash
# Install dependencies
sudo apt update && sudo apt install zsh git curl tmux neovim -y

# Clone and bootstrap
git clone git@github.com:afrijaldz/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./bootstrap.sh

# Restart WSL or log out & back in for shell change to take effect
```

## Post-install

1. **Restart your shell** or run `source ~/.zshrc`
2. **Tmux plugins**: Open tmux and press `prefix+I` (Ctrl+A then Shift+I)
3. **Customize prompt**: Run `p10k configure` if you want to tweak Powerlevel10k
4. **Neovim**: LazyVim auto-installs plugins on first launch

## Structure

```
~/dotfiles/
├── .zshrc                 # Zsh config (oh-my-zsh + p10k)
├── .zshenv                # Zsh env (sources .zshrc)
├── .p10k.zsh              # Powerlevel10k prompt config
├── .config/
│   ├── tmux/tmux.conf     # Tmux config
│   └── nvim/              # Neovim config (LazyVim)
├── bootstrap.sh           # One-command setup script
└── README.md
```
