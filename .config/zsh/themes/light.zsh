# Shell theme for a LIGHT terminal background.
#
# Two functions, because the two halves have to be applied at different points
# in .zshrc — see the ordering note there:
#   zsh_theme_prompt  runs before oh-my-zsh loads powerlevel10k
#   zsh_theme_syntax  runs after it, once zsh-syntax-highlighting exists
#
# Colors here are 256-color cube codes rather than ANSI 0-15 on purpose. The
# base 16 are defined by the terminal's own scheme, and light schemes render
# them bright: ANSI yellow lands at ~1.07:1 against white and plain vanishes.
# Cube codes are fixed RGB, so these hold up whatever the terminal does.
# Every value below clears 4.5:1 on white.

zsh_theme_prompt() {
	# The frame ornaments are the only part of the prompt drawn straight on the
	# terminal background — every other segment carries its own background and
	# so reads the same in both modes. 240 is 7.1:1 on white.
	typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%240F╭─'
	typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX='%240F├─'
	typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%240F╰─'

	# The OS icon has no background either — see .p10k.zsh.
	typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=236
}

zsh_theme_syntax() {
	(( ${+ZSH_HIGHLIGHT_STYLES} )) || return 0

	ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=160,bold'   # errors still shout
	ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=91'         # for, do, if
	ZSH_HIGHLIGHT_STYLES[alias]='fg=28'
	ZSH_HIGHLIGHT_STYLES[builtin]='fg=28'
	ZSH_HIGHLIGHT_STYLES[function]='fg=28'
	ZSH_HIGHLIGHT_STYLES[command]='fg=28'
	ZSH_HIGHLIGHT_STYLES[precommand]='fg=28,underline'
	ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=240'
	ZSH_HIGHLIGHT_STYLES[redirection]='fg=240'
	ZSH_HIGHLIGHT_STYLES[globbing]='fg=25'
	ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=25'
	ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=94'
	ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=94'
	ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=94'
	ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=30'
	ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=30'
	ZSH_HIGHLIGHT_STYLES[comment]='fg=243'              # faint but legible

	# Autosuggestions ship fg=8, which on a light scheme is often close enough
	# to the background to disappear. 245 stays clearly a suggestion.
	typeset -g ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=245'
}
