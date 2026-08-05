# dotfiles

Personal dotfiles for macOS and Linux. Consistent development environment across all machines.

## What's included

| Component | Config | Notes |
|-----------|--------|-------|
| **Shell** | `.zshrc`, `.p10k.zsh` | Zsh + oh-my-zsh + Powerlevel10k |
| **Editor** | `.config/nvim/` | Neovim with LazyVim |
| **Terminal** | `.config/tmux/tmux.conf` | Tmux with Ctrl+A prefix, vim-style navigation, TPM |
| **Prompt** | `.p10k.zsh` | Powerlevel10k (configure per-machine with `p10k configure`) |
| **Themes** | `.config/zsh/themes/`, `.config/tmux/themes/` | Light/dark, see [Light and dark](#light-and-dark) |

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
ln -sfn ~/dotfiles/.config/zsh  ~/.config/zsh

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
3. **Customize prompt**: Run `p10k configure` if you want to tweak Powerlevel10k.
   Note that it **regenerates `.p10k.zsh` from scratch**, dropping the contrast
   fixes committed here (the error segment and the Git `meta` color). Re-apply
   them from git history afterwards, or keep the diff handy.
4. **Neovim**: LazyVim auto-installs plugins on first launch
5. **Theme**: everything starts light — see [Light and dark](#light-and-dark) to switch

### tmux sessions that survive a reboot

`bootstrap.sh` installs and enables `~/.config/systemd/user/tmux.service`.
This unit starts the tmux server at login (so tmux-continuum can restore
sessions before you open a terminal) and saves state once more at
shutdown. Use the `t` alias to get in — plain `tmux` always creates a new
empty session, which makes the restored session look "lost".

```bash
systemctl --user status tmux.service    # check the unit
tmux ls                                 # list all sessions, including restored ones
```

## Light and dark

Everything defaults to **light**. Each tool switches on its own — they are not
wired together, so a terminal that is only sometimes light stays workable.

| Tool | Switch | Notes |
|------|--------|-------|
| Neovim | `<leader>ut` | monokai-nightasty; picks the style from `vim.o.background` |
| Tmux | `Prefix + T` | applies immediately, no server restart |
| Zsh | `theme` | re-execs the shell (see below) |

Two things are worth knowing if you change any of this:

**Dark is "stock" everywhere.** Neither tmux nor zsh keeps a second palette.
Tmux themepack ships no light theme, so `.config/tmux/themes/light.conf`
pre-sets its colors and the theme derives from them — dark is simply that file
not being sourced. Same idea for zsh: `zsh-syntax-highlighting`'s defaults are
already a dark theme, so `.config/zsh/themes/dark.zsh` overrides almost nothing.
One palette to maintain instead of two.

**Both toggles fight a "don't overwrite" rule.** Themepack declares its colors
with `set -goq`, which refuses to touch an option that already has a value. That
is exactly what lets the light palette win at startup, but it also means
re-sourcing on a running server does nothing — so
`.config/tmux/scripts/theme-toggle.sh` clears the old options first. In zsh the
constraint is ordering: p10k reads its colors when the theme loads and
`ZSH_HIGHLIGHT_STYLES` only exists afterwards, so a theme file defines one
function per phase and `theme` re-execs rather than reloading in place.

The zsh mode is remembered in `~/.cache/zsh-theme-mode`; delete it to fall back
to light. Colors are 256-color cube codes rather than ANSI 0–15 on purpose —
the base 16 are defined by the terminal's own scheme, and light schemes render
them bright enough that ANSI yellow drops to about 1.1:1 against white.

## Structure

```
~/dotfiles/
├── .zshrc                  # Zsh config (oh-my-zsh + p10k), picks the theme mode
├── .p10k.zsh               # Powerlevel10k prompt config
├── .config/
│   ├── zsh/themes/         # light.zsh / dark.zsh — prompt + syntax highlighting
│   ├── tmux/tmux.conf      # Tmux config
│   ├── tmux/themes/        # light.conf — palette override for tmux-themepack
│   ├── tmux/scripts/       # tmux helpers (resurrect save guard, theme toggle)
│   ├── systemd/user/       # tmux.service — auto-start server at login
│   └── nvim/               # Neovim config (LazyVim)
├── bootstrap.sh            # One-command setup script
├── KEYMAPS.md              # Tmux, Neovim & shell keybindings
└── README.md
```
