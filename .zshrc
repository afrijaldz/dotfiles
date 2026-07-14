# ==============================
# ZSH CONFIG — afrijaldz/dotfiles
# ==============================
# Shared config for all machines.
# Machine-specific overrides go in ~/.zshrc.local (not tracked in git).

# Enable Powerlevel10k instant prompt (MUST BE FIRST)
[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] &&
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# p10k prompt config (MUST BE BEFORE any output-producing commands)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Path to oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
  git
  history
  zsh-syntax-highlighting
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# Editor
export EDITOR='nvim'

# Aliases
alias td='tmux detach'
alias v='nvim'

# nnn — quit to last directory
export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
n() {
    nnn -e "$@"
    if [ -f "$NNN_TMPFILE" ]; then
        . "$NNN_TMPFILE"
        rm "$NNN_TMPFILE"
    fi
}

# nnn configuration
export NNN_OPTS="eH"
export NNN_BMS="m:$HOME/meridian;t:$HOME/trading-meteora;d:$HOME/dotfiles;D:$HOME/Downloads"
export NNN_COLORS="1234"

# Machine-specific config (NVM, Bun, Solana, PHP, etc.)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Hermes agent env (WSL)
[[ -f ~/.local/bin/env ]] && source ~/.local/bin/env

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

