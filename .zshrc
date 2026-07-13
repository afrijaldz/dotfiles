# ==============================
# ZSH CONFIG — afrijaldz/dotfiles
# ==============================
# Shared config for all machines.
# Machine-specific overrides go in ~/.zshrc.local (not tracked in git).

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# Machine-specific config (NVM, Bun, Solana, PHP, etc.)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# p10k prompt config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Hermes agent env (WSL)
[[ -f ~/.local/bin/env ]] && source ~/.local/bin/env
