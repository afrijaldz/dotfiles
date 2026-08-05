# Shell theme for a DARK terminal background.
#
# Same two-function shape as light.zsh — see the header there for why the halves
# are applied at different points.
#
# This mode is deliberately thin. zsh-syntax-highlighting's own defaults were
# designed for a dark background and are already correct there, so overriding
# them would only mean a second palette to keep in sync. Dark is therefore
# "mostly stock", the same way the tmux theme handles it.

zsh_theme_prompt() {
	# 240 is what the p10k config ships and it reads well on white, but only
	# 2.9:1 on black. 244 brings the frame back to 5.3:1 here.
	typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%244F╭─'
	typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX='%244F├─'
	typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%244F╰─'
}

zsh_theme_syntax() {
	# Nothing to do: the plugin defaults are the dark theme.
	return 0
}
