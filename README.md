# dotfiles

Personal dotfiles for macOS and Linux. Consistent development environment across all machines.

## What's included

| Component | Config | Notes |
|-----------|--------|-------|
| **Shell** | `.zshrc`, `.p10k.zsh` | Zsh + oh-my-zsh + Powerlevel10k |
| **Editor** | `.config/nvim/` | Neovim with LazyVim |
| **Terminal** | `.config/tmux/tmux.conf` | Tmux with Ctrl+A prefix, vim-style navigation, TPM |
| **Prompt** | `.p10k.zsh` | Powerlevel10k (configure per-machine with `p10k configure`) |

Git config is **not** included — see [Machine-specific config](#machine-specific-config).

## Quick start

```bash
# Clone the repo
git clone git@github.com:afrijaldz/dotfiles.git ~/dotfiles

# Run the bootstrap script (installs everything + symlinks configs)
cd ~/dotfiles && ./bootstrap.sh
```

The bootstrap script handles:
- Installing zsh (if missing) and setting it as the default shell
- Detecting your package manager (apt, dnf, pacman, zypper, apk, brew)
- Installing oh-my-zsh, Powerlevel10k, zsh plugins
- Installing TPM (Tmux Plugin Manager) and a cross-platform clipboard helper
- Symlinking all config files (backs up existing ones first)
- Auto-migrating your existing `.zshrc` to `.zshrc.local` (machine-specific config)

## Manual setup

If you prefer to do things step by step:

```bash
# 1. Clone
git clone git@github.com:afrijaldz/dotfiles.git ~/dotfiles && cd ~/dotfiles

# 2. Symlink configs (-n so re-running can't nest links inside the repo)
ln -sfn ~/dotfiles/.zshrc    ~/.zshrc
ln -sfn ~/dotfiles/.p10k.zsh ~/.p10k.zsh
ln -sfn ~/dotfiles/.config/tmux ~/.config/tmux
ln -sfn ~/dotfiles/.config/nvim ~/.config/nvim

# 3. Install oh-my-zsh (if not installed)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 4. Install TPM
git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## Machine-specific config

Place local overrides in `~/.zshrc.local` (not tracked in git).
It is automatically sourced by the shared `.zshrc`.

`~/.gitconfig` is machine-local too and is neither tracked nor symlinked. It is
the file `gh auth login` writes to, and it carries host-specific absolute paths
(`/usr/bin/gh` on Linux vs `/opt/homebrew/bin/gh` on macOS). Set your identity
per machine:

```bash
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

## Post-install

1. **Restart your shell** or run `source ~/.zshrc`
2. **Tmux plugins**: Open tmux and press `prefix+I` (Ctrl+A then Shift+I)
3. **Customize prompt**: Run `p10k configure` if you want to tweak Powerlevel10k
4. **Neovim**: LazyVim auto-installs plugins on first launch

## Structure

```
~/dotfiles/
├── .zshrc                  # Zsh config (oh-my-zsh + p10k)
├── .p10k.zsh               # Powerlevel10k prompt config
├── .config/
│   ├── tmux/tmux.conf      # Tmux config
│   └── nvim/               # Neovim config (LazyVim)
├── bootstrap.sh            # One-command setup script
├── KEYMAPS.md              # Tmux & Neovim keybindings
└── README.md
```
