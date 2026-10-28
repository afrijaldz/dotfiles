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

# Same reason as in theme-toggle.sh: TPM's plugin dir depends on where the
# config lives, so read the path TPM exported instead of assuming one.
PLUGINS_DIR="$(tmux show-environment -g TMUX_PLUGIN_MANAGER_PATH 2>/dev/null |
	sed -n 's/^TMUX_PLUGIN_MANAGER_PATH=//p')"
[ -n "$PLUGINS_DIR" ] || PLUGINS_DIR="${HOME}/.tmux/plugins"
SAVE_SCRIPT="${PLUGINS_DIR%/}/tmux-resurrect/scripts/save.sh"

tmux has-session >/dev/null 2>&1 || exit 0
[ -x "$SAVE_SCRIPT" ] || exit 0

"$SAVE_SCRIPT" quiet

# Second safety belt: if the save we just made turns out to be empty anyway,
# point `last` back to the most recent valid save file and drop the empty one.
"$(dirname "$0")/resurrect-repair-last.sh"
