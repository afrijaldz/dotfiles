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

# ------------------------------
# Theme mode (light / dark)
# ------------------------------
# A theme has to be applied in two phases, because its two halves become
# settable at different moments:
#   - powerlevel10k reads POWERLEVEL9K_* when oh-my-zsh loads the theme, so
#     prompt colors must be set BEFORE that.
#   - ZSH_HIGHLIGHT_STYLES only exists once oh-my-zsh has loaded
#     zsh-syntax-highlighting, so those must be set AFTER it.
# Each theme file defines one function per phase; they're called in place below.
# Switch with `theme light|dark|toggle` (defined further down).
ZSH_THEME_MODE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh-theme-mode"
ZSH_THEME_MODE=light
[[ -r $ZSH_THEME_MODE_FILE ]] && ZSH_THEME_MODE="$(<$ZSH_THEME_MODE_FILE)"
[[ $ZSH_THEME_MODE == (light|dark) ]] || ZSH_THEME_MODE=light
[[ -r ~/.config/zsh/themes/${ZSH_THEME_MODE}.zsh ]] &&
  source ~/.config/zsh/themes/${ZSH_THEME_MODE}.zsh
(( $+functions[zsh_theme_prompt] )) && zsh_theme_prompt   # phase 1: before oh-my-zsh

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

(( $+functions[zsh_theme_syntax] )) && zsh_theme_syntax   # phase 2: after oh-my-zsh

# Switch the shell theme. Re-execs rather than re-applying in place: p10k reads
# its colors when the theme loads, and zsh-syntax-highlighting caches its styles,
# so a fresh shell is the only way both halves land. `exec` keeps the same
# terminal and the same shell level.
theme() {
  local mode="${1:-toggle}"
  [[ $mode == toggle ]] && { [[ $ZSH_THEME_MODE == light ]] && mode=dark || mode=light; }
  if [[ $mode != (light|dark) ]]; then
    print -u2 "theme: expected light, dark or toggle — got '$mode'"
    return 1
  fi
  mkdir -p "${ZSH_THEME_MODE_FILE:h}"
  print -r -- "$mode" > "$ZSH_THEME_MODE_FILE"
  exec zsh
}

# Editor
export EDITOR='nvim'

# Aliases
# Plain `tmux` always creates a NEW empty session — the old session that
# continuum restored still exists but stays hidden, so it feels "lost".
# `t` always attaches to an existing session first.
alias t='tmux attach 2>/dev/null || tmux new -s main'
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
# Only bookmarks that exist on every machine live here. Per-machine ones go in
# ~/.zshrc.local, which is sourced below — append there rather than reassigning:
#   export NNN_BMS="$NNN_BMS;w:$HOME/some-project"
export NNN_OPTS="eH"
export NNN_BMS="d:$HOME/dotfiles;D:$HOME/Downloads"
export NNN_COLORS="1234"

# Bitwarden SSH agent — override gnome-keyring agent only when the
# Bitwarden desktop socket exists (safe on machines without it running)
[[ -S "$HOME/.bitwarden-ssh-agent.sock" ]] && export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"

# Machine-specific config — anything tied to one machine's paths, toolchains or
# projects (version managers, language runtimes, extra PATH entries, local
# bookmarks). Not tracked in git; see zshrc.local.template for a starting point.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# atuin — put the binary on PATH, THEN load the shell integration (Ctrl-R /
# history search). Both guarded so a machine without atuin doesn't error. The
# init must come after the PATH line, or `atuin` isn't found yet.
[[ -f "$HOME/.atuin/bin/env" ]] && source "$HOME/.atuin/bin/env"
command -v atuin &>/dev/null && eval "$(atuin init zsh)"

# Safety net: p10k's config (~/.p10k.zsh) does `setopt no_aliases` while it
# loads and restores it at the end. A truncated/regenerated config can drop
# that restore, leaking `no_aliases` globally and silently killing every alias
# (v, td, …). Force `aliases` back on as the last line so they always work.
#
# Keep this last. Installers that append to ~/.zshrc write into this tracked
# file, because ~/.zshrc is a symlink to it — move anything they add into
# ~/.zshrc.local instead of leaving it below this line.
setopt aliases
