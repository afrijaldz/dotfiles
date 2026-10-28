# dotfiles

Personal dotfiles for macOS and Linux. Consistent development environment across all machines.

## What's included

| Component | Config | Notes |
|-----------|--------|-------|
| **Shell** | `.zshrc`, `.p10k.zsh` | Zsh + oh-my-zsh + Powerlevel10k |
| **Editor** | `.config/nvim/` | Neovim with LazyVim |
| **Terminal** | `.config/tmux/tmux.conf` | Tmux with Ctrl+A prefix (opens a hint menu), vim-style navigation, TPM |
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
- Installing TPM (Tmux Plugin Manager) and the cross-platform tmux paste helper
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
2. **Tmux plugins**: Open tmux and press `Ctrl+A Space I` (Space skips the
   prefix hint menu, which does not list TPM keys)
3. **Customize prompt**: Run `p10k configure` if you want to tweak Powerlevel10k.
   Note that it **regenerates `.p10k.zsh` from scratch**, dropping the contrast
   fixes committed here (the error segment, the Git `meta` color, and the
   transparent OS icon). Re-apply them from git history afterwards, or keep the
   diff handy.
4. **Neovim**: LazyVim auto-installs plugins on first launch
5. **Theme**: everything starts light — see [Light and dark](#light-and-dark) to switch

### tmux sessions that survive a reboot

The tmux server is started at login so tmux-continuum can restore sessions
before you open a terminal. Use the `t` alias to get in — plain `tmux` always
creates a new empty session, which makes the restored session look "lost".

The mechanism depends on the OS, and `bootstrap.sh` picks it for you:

| | Started by | Saves at shutdown |
|---|---|---|
| **Linux (systemd)** | `~/.config/systemd/user/tmux.service`, symlinked and enabled | no; relies on continuum's autosave and the detach hook |
| **macOS** | `~/Library/LaunchAgents/dotfiles.tmux.plist`, generated at install time | no; relies on continuum's autosave and the detach hook |

The plist is generated rather than tracked because it needs the absolute path
to `tmux`, which differs per machine. On macOS `@continuum-boot` is deliberately
left off: continuum's own macOS auto-start opens a Terminal.app window at every
login, where the launch agent starts the server headlessly.

```bash
tmux ls                                        # sessions, including restored ones
systemctl --user status tmux.service           # Linux: check the unit
launchctl print "gui/$(id -u)/dotfiles.tmux"   # macOS: check the agent
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

## Daily recap

`.claude/hooks/daily-recap.py` writes a short summary of each day's work into a
Markdown notes folder (an Obsidian vault, in practice — but it is just files). A
`SessionStart` hook runs it whenever Claude Code opens; it prints nothing unless
a day is due, so most sessions pay nothing for it.

The day boundary is midnight and today is never written up — a day is only
recapped once it is over, and the catch-up happens the next time Claude Code is
opened rather than on a timer.

Two sources, both already summarized and cheap to read: git commits authored by
you across every repo under `$HOME`, and Claude Code session titles. No shell
history is read and no conversation content is opened.

**Everything personal lives outside this repo.** The script is generic and reads
`~/.config/daily-recap.json`, which is not tracked here — this repo is public.
Without that file the hook is inert, so nothing happens on a machine that has
not opted in.

```json
{
  "notes_dir": "~/notes",
  "default_folder": "Daily",
  "language": "English",
  "lookback_days": 7,
  "routes": [
    { "name": "work", "path": "~/src/acme", "folder": "Projects/Acme/daily" }
  ]
}
```

Each route sends work done under `path` to `folder` instead of the default one;
first match wins, and `name` is the bucket you pass to `write`. With no routes,
everything lands in `default_folder`.

Notes folders often have no version history, so the file handling is
deliberately conservative and lives in the script rather than being re-derived
each run:

- notes are only ever appended to, inside one `<!-- daily-recap:... -->` block
- that block is the only region ever rewritten; anything you wrote by hand is
  never touched
- daily filenames tend to exist with both one and two spaces, so an existing
  note is matched with either before a new one is created

```bash
.claude/hooks/daily-recap.py pending          # what is due, as JSON
.claude/hooks/daily-recap.py collect <date>   # raw material for one day
echo '- ...' | .claude/hooks/daily-recap.py write <date> <bucket>
```

### Turning it on again

`./bootstrap.sh` does it. It links `~/.claude/hooks` and merges the `SessionStart`
entry into `~/.claude/settings.json`, leaving every other setting alone. Running
it twice is a no-op, and it refuses to touch the file if it isn't valid JSON.

**Switching Claude accounts changes nothing here.** The account lives in
`~/.claude/.credentials.json`; the hook lives in `~/.claude/settings.json`, which
is machine config. Logging in as someone else replaces the former and never
touches the latter, so the recap keeps running.

What does need re-enabling is a **new machine**, or a `~/.claude` that got wiped
— both covered by re-running `bootstrap.sh`. To check whether it is live:

```bash
jq '.hooks.SessionStart' ~/.claude/settings.json    # should list daily-recap.py
.claude/hooks/daily-recap.py pending                # what it would write next
```

Claude Code only re-reads settings at startup, so a freshly registered hook
takes effect in the next session (or after opening `/hooks` once).

## Structure

```
~/dotfiles/
├── .claude/hooks/          # daily-recap.py — daily work summary into Obsidian
├── .zshrc                  # Zsh config (oh-my-zsh + p10k), picks the theme mode
├── .p10k.zsh               # Powerlevel10k prompt config
├── .config/
│   ├── zsh/themes/         # light.zsh / dark.zsh — prompt + syntax highlighting
│   ├── tmux/tmux.conf      # Tmux config
│   ├── tmux/prefix-menu*.conf # The hint menu that opens on Ctrl+A
│   ├── tmux/themes/        # light.conf — palette override for tmux-themepack
│   ├── tmux/scripts/       # tmux helpers (resurrect save guard, theme toggle)
│   ├── systemd/user/       # tmux.service — auto-start server at login (Linux;
│   │                       #   macOS gets a launchd agent generated by bootstrap)
│   └── nvim/               # Neovim config (LazyVim)
├── bootstrap.sh            # One-command setup script
├── KEYMAPS.md              # Tmux, Neovim & shell keybindings
└── README.md
```
