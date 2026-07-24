#!/bin/bash
# ==============================
# Bootstrap — afrijaldz/dotfiles
# ==============================
# Usage: cd ~/dotfiles && ./bootstrap.sh
# Installs dependencies & symlinks config files.
# Supports macOS and Linux (any distro).
# ==============================

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "==> Dotfiles directory: $DOTFILES_DIR"

# Detect OS
OS="$(uname -s)"
case "$OS" in
  Darwin)  PLATFORM="macos"  ;;
  Linux)   PLATFORM="linux"  ;;
  *)       echo "Unknown OS: $OS"; exit 1 ;;
esac
echo "==> Platform: $PLATFORM"

# Detect package manager
detect_pkg_manager() {
  if command -v brew &>/dev/null; then
    PKG_MANAGER="brew"
    PKG_INSTALL="brew install"
  elif command -v apt-get &>/dev/null; then
    PKG_MANAGER="apt"
    PKG_INSTALL="sudo apt-get install -y"
    PKG_UPDATE="sudo apt-get update -qq"
  elif command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
    PKG_INSTALL="sudo dnf install -y"
  elif command -v pacman &>/dev/null; then
    PKG_MANAGER="pacman"
    PKG_INSTALL="sudo pacman -S --noconfirm"
  elif command -v zypper &>/dev/null; then
    PKG_MANAGER="zypper"
    PKG_INSTALL="sudo zypper install -y"
  elif command -v apk &>/dev/null; then
    PKG_MANAGER="apk"
    PKG_INSTALL="sudo apk add"
  else
    PKG_MANAGER=""
    echo "Warning: No supported package manager found."
    echo "  Please install zsh, git, curl, tmux, neovim manually."
  fi
}
detect_pkg_manager
echo "==> Package manager: ${PKG_MANAGER:-none}"

# ──────────────────────────────
# 1. Install Homebrew (macOS)
# ──────────────────────────────
if [ "$PLATFORM" = "macos" ] && [ "$PKG_MANAGER" != "brew" ]; then
  echo "==> Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  PKG_MANAGER="brew"
  PKG_INSTALL="brew install"
  echo "==> Homebrew installed"
fi

# ──────────────────────────────
# 2. Check / install zsh
# ──────────────────────────────
if ! command -v zsh &>/dev/null; then
  echo "==> zsh not found. Installing..."
  case "$PKG_MANAGER" in
    brew) $PKG_INSTALL zsh ;;
    apt)  $PKG_UPDATE && $PKG_INSTALL zsh ;;
    *)    $PKG_INSTALL zsh ;;
  esac
fi

# Set zsh as default shell if not already
if [ "$SHELL" != "$(command -v zsh)" ]; then
  echo "==> Changing default shell to zsh..."
  # Don't let a failed chsh (managed/LDAP account, no password) abort the run —
  # the symlinking below matters more than the shell change.
  if chsh -s "$(command -v zsh)"; then
    echo "    You'll need to log out and back in (or restart your session)."
  else
    echo "    Warning: chsh failed. Change your login shell manually later."
  fi
fi

# ──────────────────────────────
# 3. Install Nerd Font
# ──────────────────────────────
NERD_FONT_INSTALLED=false

# Check if any Nerd Font is already installed
for pattern in "MesloLGS" "JetBrainsMono" "FiraCode" "Fira Code" "Hack" "Nerd Font" "NerdFont"; do
  if fc-list 2>/dev/null | grep -iq "$pattern"; then
    NERD_FONT_INSTALLED=true
    break
  fi
done

if [ "$NERD_FONT_INSTALLED" = false ]; then
  case "$PKG_MANAGER" in
    brew)
      echo "==> Installing MesloLGS Nerd Font (recommended for p10k)..."
      brew tap --quiet homebrew/cask-fonts 2>/dev/null || true
      brew install --quiet --cask font-meslo-lg-nerd-font 2>/dev/null && NERD_FONT_INSTALLED=true || true
      ;;
  esac
fi

# ──────────────────────────────
# 4. Install oh-my-zsh
# ──────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "==> oh-my-zsh already installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ──────────────────────────────
# 5. Install Powerlevel10k
# ──────────────────────────────
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo "==> Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
  echo "==> Powerlevel10k already installed"
fi

# ──────────────────────────────
# 6. Install zsh plugins
# ──────────────────────────────
install_zsh_plugin() {
  local name="$1"
  local url="$2"
  local target="$ZSH_CUSTOM/plugins/$name"
  if [ ! -d "$target" ]; then
    echo "==> Installing zsh plugin: $name"
    git clone --depth=1 "$url" "$target"
  else
    echo "==> zsh plugin $name already installed"
  fi
}

install_zsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
install_zsh_plugin "zsh-autosuggestions"     "https://github.com/zsh-users/zsh-autosuggestions.git"

# ──────────────────────────────
# 7. Install TPM (tmux plugin manager)
# ──────────────────────────────
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  echo "==> Installing TPM..."
  mkdir -p "$HOME/.tmux/plugins"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  echo "==> TPM already installed"
fi

# ──────────────────────────────
# 8. Install atuin (sync shell history)
# ──────────────────────────────
if ! command -v atuin &>/dev/null; then
  echo "==> Installing atuin..."
  case "$PKG_MANAGER" in
    brew) $PKG_INSTALL atuin ;;
    *)
      # Use official installer (works on all Linux distros)
      bash <(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh) 2>/dev/null || true
      ;;
  esac
fi

if command -v atuin &>/dev/null; then
  echo "==> atuin installed."

  # Shell integration (eval "$(atuin init zsh)") lives in the shared .zshrc,
  # guarded on the binary being present — so nothing to add here. Adding it to
  # .zshrc.local too would run atuin init twice.

  # Import existing history if atuin db is empty
  if [ ! -f "$HOME/.local/share/atuin/history.db" ]; then
    if [ -f "$HOME/.bash_history" ] && [ -s "$HOME/.bash_history" ]; then
      echo "==> Importing bash history to atuin..."
      atuin import bash 2>/dev/null && echo "    done"
    fi
    if [ -f "$HOME/.zsh_history" ] && [ -s "$HOME/.zsh_history" ]; then
      echo "==> Importing zsh history to atuin..."
      atuin import zsh 2>/dev/null && echo "    done"
    fi
  fi
else
  echo "==> atuin installation skipped (could not install)"
fi

# ──────────────────────────────
# 9. Install CLI tools (tmux, neovim, nnn)
# ──────────────────────────────
# $1 = command to probe, $2 = package name (defaults to $1)
install_pkg() {
  local cmd="$1"
  local pkg="${2:-$1}"
  if command -v "$cmd" &>/dev/null; then
    echo "==> $pkg already installed"
    return
  fi
  echo "==> Installing $pkg..."
  case "$PKG_MANAGER" in
    brew) $PKG_INSTALL "$pkg" ;;
    apt)  $PKG_UPDATE && $PKG_INSTALL "$pkg" ;;
    "")   echo "    skipped — no package manager detected, install $pkg manually" ;;
    *)    $PKG_INSTALL "$pkg" ;;
  esac
}

install_pkg tmux
install_pkg nvim neovim
install_pkg nnn

# ──────────────────────────────
# 10. Install tmux clipboard helper
# ──────────────────────────────
TMUX_BIN_DIR="$HOME/.local/bin"
mkdir -p "$TMUX_BIN_DIR"

cat > "$TMUX_BIN_DIR/tmux-yank" << 'EOF'
#!/bin/bash
# Cross-platform clipboard yank for tmux
# Detects available clipboard tool and pipes stdin to it.

if command -v pbcopy &>/dev/null; then
  # macOS
  pbcopy
elif command -v clip.exe &>/dev/null; then
  # WSL
  clip.exe
elif command -v wl-copy &>/dev/null; then
  # Wayland
  wl-copy
elif command -v xclip &>/dev/null; then
  # X11
  xclip -selection clipboard
elif command -v xsel &>/dev/null; then
  # X11 (alternative)
  xsel --clipboard --input
else
  # Fallback: show in tmux message
  cat > /tmp/tmux-yank.txt
  tmux display-message "No clipboard tool found. Yank saved to /tmp/tmux-yank.txt"
fi
EOF
chmod +x "$TMUX_BIN_DIR/tmux-yank"
echo "==> Installed tmux-yank to $TMUX_BIN_DIR/tmux-yank"

# ──────────────────────────────
# 11. Migrate existing .zshrc → .zshrc.local
# ──────────────────────────────
# On a machine with its own pre-existing ~/.zshrc, pull every line that isn't
# already in the shared .zshrc into ~/.zshrc.local, so machine-specific config
# survives the symlink swap below instead of only being backed up.
#
# Runs whenever ~/.zshrc is a real file (not our symlink) — crucially NOT gated
# on .zshrc.local being absent, because the atuin step above may have already
# created it. Extracted lines are APPENDED and de-duplicated, never overwriting
# what's already there.
OLD_ZSH="$HOME/.zshrc"
DOTFILES_ZSH="$DOTFILES_DIR/.zshrc"
LOCAL_ZSH="$HOME/.zshrc.local"

if [ -f "$OLD_ZSH" ] && [ ! -L "$OLD_ZSH" ]; then
  echo "==> Migrating machine-specific config from old .zshrc to .zshrc.local..."

  python3 -c "
import os

old_lines = [l.rstrip() for l in open('$OLD_ZSH')]
shared = set(l.rstrip() for l in open('$DOTFILES_ZSH'))

local_path = '$LOCAL_ZSH'
existing = [l.rstrip() for l in open(local_path)] if os.path.exists(local_path) else []
existing_set = set(existing)

migrated = []
prev_blank = False
for line in old_lines:
    # Skip lines the shared .zshrc already provides, or that .zshrc.local has.
    if line in shared or (line.strip() and line in existing_set):
        prev_blank = False
        continue
    if line == '':
        if prev_blank:
            continue
        prev_blank = True
    else:
        prev_blank = False
    migrated.append(line)

# Trim leading/trailing blank lines from the migrated block.
while migrated and migrated[0] == '':
    migrated.pop(0)
while migrated and migrated[-1] == '':
    migrated.pop()

if migrated:
    with open(local_path, 'a') as f:
        if existing and existing[-1].strip() != '':
            f.write('\n')
        f.write('# --- migrated from a previous ~/.zshrc ---\n')
        f.write('\n'.join(migrated) + '\n')
    print('    migrated %d line(s) into %s' % (len(migrated), local_path))
else:
    print('    nothing to migrate (already covered by shared .zshrc / .zshrc.local)')
"
fi

# ──────────────────────────────
# 12. Symlink config files
# ──────────────────────────────
echo "==> Symlinking config files..."

# Backup existing dotfiles — directory is created lazily, only if something
# actually needs backing up, so repeat runs don't litter $HOME with empty dirs.
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

link_file() {
  local src="$1"
  local dst="$2"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ ! -L "$dst" ] || [ "$(readlink "$dst")" != "$src" ]; then
      mkdir -p "$BACKUP_DIR"
      mv "$dst" "$BACKUP_DIR/" 2>/dev/null || true
      echo "    backed up: $dst"
    fi
  fi
  # -n is essential: without it, when $dst is already a symlink to a directory,
  # ln follows it and creates $src/$(basename $src) inside the repo instead.
  ln -sfn "$src" "$dst"
  echo "    linked: $dst -> $src"
}

# Files in home directory
link_file "$DOTFILES_DIR/.zshrc"       "$HOME/.zshrc"
link_file "$DOTFILES_DIR/.p10k.zsh"    "$HOME/.p10k.zsh"
# ~/.gitconfig is intentionally NOT linked — it stays machine-local, since it's
# where `gh auth login` writes and it holds host-specific absolute paths.

# Files in ~/.config/
mkdir -p "$HOME/.config"
link_file "$DOTFILES_DIR/.config/tmux" "$HOME/.config/tmux"
link_file "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"

# ──────────────────────────────
# 13. Done — summary
# ──────────────────────────────
echo ""
echo "==> Bootstrap complete!"
if [ -d "$BACKUP_DIR" ]; then
  echo "    Backup of old dotfiles: $BACKUP_DIR"
fi
echo ""

echo "Next steps:"
echo "  1. Restart your shell or run: source ~/.zshrc"
echo "  2. Log out & back in if default shell was changed"
echo "  3. Open tmux and press prefix+I to install TPM plugins"
echo "  4. Run 'p10k configure' if you want to customize the prompt"

if command -v atuin &>/dev/null; then
  if ! atuin status 2>/dev/null | grep -q "Logged in"; then
    echo "  5. Setup atuin (sync shell history):"
    echo "     First machine:  atuin register -u <username> -e <email>"
    echo "     Other machines: atuin login -u <username>"
    echo "     Then run:       atuin sync"
  fi
fi

if [ "$NERD_FONT_INSTALLED" = false ]; then
  echo ""
  echo "==> No Nerd Font detected. Powerlevel10k needs one for icons."
  case "$PKG_MANAGER" in
    brew)
      echo "    Install: brew install --cask font-meslo-lg-nerd-font" ;;
    *)
      echo "    Download & install a Nerd Font (e.g. MesloLGS NF):"
      echo "    https://github.com/romkatv/powerlevel10k#fonts"
      echo "    Then configure your terminal to use it." ;;
  esac
fi
