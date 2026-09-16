#!/usr/bin/env zsh
# Ask for one line of input in a tmux popup instead of the status-line prompt,
# which sits bottom-left where it is easy to miss. Meant to be run through
# `display-popup -E`, so the popup closes as soon as this script exits.
#
#   prompt-popup.sh window    rename the current window
#   prompt-popup.sh session   rename the current session
#   prompt-popup.sh command   run a tmux command, like the `:` prompt
#
# Enter applies, Ctrl+C / Ctrl+D cancels. Errors stay on screen until a key
# is pressed so they are not lost when the popup closes.
set -u

case "${1:-}" in
	window)  label='Window name'  ; input=$(tmux display-message -p '#W') ;;
	session) label='Session name' ; input=$(tmux display-message -p '#S') ;;
	command) label=':'            ; input='' ;;
	*) echo "usage: $0 window|session|command" >&2; exit 2 ;;
esac

vared -p "${label} " input || exit 0
[ -z "$input" ] && exit 0

case "$1" in
	window)  out=$(tmux rename-window "$input" 2>&1) ;;
	session) out=$(tmux rename-session "$input" 2>&1) ;;
	command) out=$(tmux ${(Q)${(z)input}} 2>&1) ;;  # split like a shell, then unquote
esac
status=$?

if [ $status -ne 0 ]; then
	printf '%s\n[press any key]' "$out"
	read -sk1
fi
exit $status
