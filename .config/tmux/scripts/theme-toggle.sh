#!/usr/bin/env bash
# Switch the status theme between themepack's stock dark colors and our light
# palette, at runtime, without restarting the server.
#
# Why a script and not just `source-file`: themepack declares every one of its
# colors with `set -goq`, and `-o` refuses to overwrite an option that already
# has a value. That is exactly what makes themes/light.conf work at startup —
# but on a server that has already loaded the theme once, every @theme-* and
# @powerline-* option is set, so re-sourcing anything is a no-op and the old
# colors survive. The options have to be cleared first.
#
# Usage: theme-toggle.sh [toggle|light|dark]   (default: toggle)

set -u

CONF_DIR="${HOME}/.config/tmux"

# Where TPM actually puts plugins: ~/.config/tmux/plugins/ when the config lives
# at the XDG path, ~/.tmux/plugins/ otherwise. Hardcoding either one breaks on
# the other layout, so ask tmux for the path TPM exported.
PLUGINS_DIR="$(tmux show-environment -g TMUX_PLUGIN_MANAGER_PATH 2>/dev/null |
	sed -n 's/^TMUX_PLUGIN_MANAGER_PATH=//p')"
[ -n "$PLUGINS_DIR" ] || PLUGINS_DIR="${HOME}/.tmux/plugins"
PLUGINS_DIR="${PLUGINS_DIR%/}"

THEMEPACK_DIR="${PLUGINS_DIR}/tmux-themepack"

# Centered one-line dialog, closed by any key. display-message would put the
# text bottom-left on the status line where it is easy to miss.
notify() {
	tmux display-menu -T ' tmux ' -x C -y C "$1" '' ''
}

mode="${1:-toggle}"

if [ "$mode" = "toggle" ]; then
	# Absent on a server that has never toggled; startup sources light.conf.
	current="$(tmux show -gv @theme-mode 2>/dev/null)"
	[ -n "$current" ] || current="light"
	[ "$current" = "light" ] && mode="dark" || mode="light"
fi

case "$mode" in
	light | dark) ;;
	*)
		notify "theme-toggle: unknown mode '${mode}'"
		exit 1
		;;
esac

# Which themepack theme to reload. Read it before clearing, because @themepack
# itself matches the @theme* prefix below and must survive.
themepack="$(tmux show -gv @themepack 2>/dev/null)"
[ -n "$themepack" ] || themepack="powerline/default/cyan"

theme_file="${THEMEPACK_DIR}/${themepack}.tmuxtheme"
if [ ! -f "$theme_file" ]; then
	notify "theme-toggle: no such theme '${themepack}'"
	exit 1
fi

# Clear the previous load. Everything themepack sets is matched here — @theme-*,
# @powerline-*, @themepack-*-format — except @themepack, which is the user's
# theme choice from tmux.conf rather than something the theme file writes.
clear_opts() {
	local scope="$1"
	tmux show "$scope" 2>/dev/null |
		grep -oE '^@(theme|powerline|themepack)[a-z0-9_-]*' |
		grep -vx '@themepack' |
		while read -r opt; do
			tmux set "${scope}u" "$opt" 2>/dev/null
		done
}
clear_opts -g
clear_opts -gw

[ "$mode" = "light" ] && tmux source-file "${CONF_DIR}/themes/light.conf"

tmux source-file "$theme_file"
tmux set -g @theme-mode "$mode"
notify "tmux theme: ${mode}"
