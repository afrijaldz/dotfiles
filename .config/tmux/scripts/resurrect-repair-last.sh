#!/usr/bin/env bash
# Point tmux-resurrect's `last` symlink back at the newest save that holds at
# least one pane when it points at an empty save or at nothing at all.
#
# Either state makes the next restore bring back no sessions. Both happen at
# shutdown: save.sh run against a dying server writes a 0-byte save and links
# `last` to it, and a save guard killed halfway through can leave `last`
# pointing at a file it already removed. A save can also be "empty" without
# being 0 bytes: one taken while the server has no panes holds only the
# `state` line, and restoring it brings back nothing just the same. So this
# runs from the save guard after every save and again from the systemd unit
# before the server starts.
#
# The symlink is moved before the empty file is removed, so a kill between the
# two steps never leaves `last` dangling.

set -u

RESURRECT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect"
LAST_LINK="${RESURRECT_DIR}/last"

# Plain `readlink`, not `readlink -f`: resurrect writes `last` as a relative
# symlink to a sibling file, so the bare target name is all we need — and `-f`
# is GNU-only on older macOS.
last_target="$(readlink "$LAST_LINK" 2>/dev/null || true)"
[ -n "$last_target" ] || exit 0
last_file="${RESURRECT_DIR}/$(basename "$last_target")"

# A save is usable only if it has at least one `pane` line.
has_panes() {
	grep -q '^pane' "$1" 2>/dev/null
}

# Healthy: `last` points at a save with panes.
has_panes "$last_file" && exit 0

# `find -printf` is GNU-only, so the loop strips directories with basename.
newest_valid=""
for f in "$RESURRECT_DIR"/tmux_resurrect_*.txt; do
	has_panes "$f" || continue
	name="$(basename "$f")"
	[ "$name" \> "$newest_valid" ] && newest_valid="$name"
done
[ -n "$newest_valid" ] || exit 0

ln -sfn "$newest_valid" "$LAST_LINK"
[ -f "$last_file" ] && [ ! -s "$last_file" ] && rm -f "$last_file"
exit 0
