#!/usr/bin/env bash
# Safe wrapper around tmux-resurrect's save.sh.
#
# Why it's needed: save.sh run when the tmux server is ALREADY dead still creates
# a new save file — but it's 0 bytes — and then updates the `last` symlink to it.
# The next restore then brings back "nothing", i.e. all sessions are lost. This
# happens easily in the systemd unit's ExecStop during shutdown, because the
# server may already have been killed before ExecStop gets to run.
#
# Guard here: if there's no live server/session, don't save at all —
# leave the last valid save as `last`.

set -u

RESURRECT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect"
SAVE_SCRIPT="${HOME}/.config/tmux/plugins/tmux-resurrect/scripts/save.sh"

tmux has-session >/dev/null 2>&1 || exit 0
[ -x "$SAVE_SCRIPT" ] || exit 0

"$SAVE_SCRIPT" quiet

# Second safety belt: if the save we just made turns out to be empty anyway, drop it
# and point `last` back to the most recent valid save file.
last_file="$(readlink -f "${RESURRECT_DIR}/last" 2>/dev/null || true)"
if [ -n "$last_file" ] && [ -f "$last_file" ] && [ ! -s "$last_file" ]; then
	rm -f "$last_file"
	newest_valid="$(find "$RESURRECT_DIR" -maxdepth 1 -name 'tmux_resurrect_*.txt' -size +0c \
		-printf '%f\n' 2>/dev/null | sort | tail -1)"
	[ -n "$newest_valid" ] && ln -sfn "$newest_valid" "${RESURRECT_DIR}/last"
fi
