#!/bin/bash
# ==============================
# Bootstrap — afrijaldz/dotfiles
# ==============================
# Usage: cd ~/dotfiles && ./bootstrap.sh
# Installs dependencies & symlinks config files.
# Supports macOS and Linux (WSL/Ubuntu).
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

# ──────────────────────────────
# 1. Check / install zsh
# ──────────────────────────────
if ! command -v zsh &>/dev/null; then
  echo "==> zsh not found. Installing..."
  case "$PLATFORM" in
    macos) brew install zsh ;;
    linux) sudo apt-get update -qq && sudo apt-get install -y -qq zsh ;;
  esac
fi

# Set zsh as default shell if not already
if [ "$SHELL" != "$(command -v zsh)" ]; then
  echo "==> Changing default shell to zsh..."
  chsh -s "$(command -v zsh)"
  echo "    You'll need to log out and back in (or restart WSL)."
fi

# ──────────────────────────────
# 2. Install Nerd Font
# ──────────────────────────────
FONT_NAME="MesloLGS NF"
FONT_INSTALLED=false

case "$PLATFORM" in
  macos)
    if fc-list | grep -iq "MesloLGS"; then
      FONT_INSTALLED=true
    else
      echo "==> Installing MesloLGS Nerd Font..."
      brew tap --quiet homebrew/cask-fonts 2>/dev/null || true
      brew install --quiet --cask font-meslo-lg-nerd-font 2>/dev/null && FONT_INSTALLED=true || true
    fi
    ;;
  linux)
    # Check if MesloLGS is available on the system
    if fc-list 2>/dev/null | grep -iq "MesloLGS"; then
      FONT_INSTALLED=true
    fi
    ;;
esac

# ──────────────────────────────
# 3. Install oh-my-zsh
# ──────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "==> oh-my-zsh already installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ──────────────────────────────
# 4. Install Powerlevel10k
# ──────────────────────────────
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo "==> Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
  echo "==> Powerlevel10k already installed"
fi

# ──────────────────────────────
# 5. Install zsh plugins
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
# 6. Install TPM (tmux plugin manager)
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
# 7. Symlink config files
# ──────────────────────────────
echo "==> Symlinking config files..."

# Backup existing dotfiles
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

link_file() {
  local src="$1"
  local dst="$2"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ ! -L "$dst" ] || [ "$(readlink "$dst")" != "$src" ]; then
      mv "$dst" "$BACKUP_DIR/" 2>/dev/null || true
      echo "    backed up: $dst"
    fi
  fi
  ln -sf "$src" "$dst"
  echo "    linked: $dst -> $src"
}

# Files in home directory
link_file "$DOTFILES_DIR/.zshrc"       "$HOME/.zshrc"
link_file "$DOTFILES_DIR/.zshenv"      "$HOME/.zshenv"
link_file "$DOTFILES_DIR/.p10k.zsh"    "$HOME/.p10k.zsh"

# Files in ~/.config/
mkdir -p "$HOME/.config"
link_file "$DOTFILES_DIR/.config/tmux" "$HOME/.config/tmux"
link_file "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"

# ──────────────────────────────
# 8. Done — summary
# ──────────────────────────────
echo ""
echo "==> Bootstrap complete!"
echo "    Backup of old dotfiles: $BACKUP_DIR"
echo ""

echo "Next steps:"
echo "  1. Restart your shell or run: source ~/.zshrc"
echo "  2. Log out & back in (or restart WSL) if default shell was changed"
echo "  3. Open tmux and press prefix+I to install TPM plugins"
echo "  4. Run 'p10k configure' if you want to customize the prompt"

if [ "$FONT_INSTALLED" = false ]; then
  echo ""
  echo "==> Font: $FONT_NAME not detected."
  case "$PLATFORM" in
    macos)
      echo "    Install manually: brew install --cask font-meslo-lg-nerd-font" ;;
    linux)
      echo "    Download & install MesloLGS NF on your Windows host:"
      echo "    https://github.com/romkatv/powerlevel10k#manual-font-installation"
      echo "    Then set font in Windows Terminal settings to 'MesloLGS NF'" ;;
  esac
fi
