#!/usr/bin/env bash
#
# Patch tmux-resurrect so a pane with an empty title keeps its working
# directory across a restore.
#
# The save file is tab-separated and resurrect parses it with
# `while IFS=$'\t' read ... pane_title dir pane_active ...`. Tab is an IFS
# whitespace character, so the shell folds runs of tabs into one delimiter.
# A pane whose #{pane_title} is empty therefore loses that field entirely and
# every column after it shifts one to the left: `dir` receives pane_active
# ("0"/"1"), remove_first_char turns that into "", and the pane is recreated
# in $HOME with no process restored. Panes that ran a program which writes its
# own title (Claude Code, for one) end up with an empty title once it exits,
# which is why those are the panes that come back in the wrong directory.
#
# The fix is the one resurrect already uses for window_flags and
# pane_current_path: prefix the field with ":" so it is never empty, and strip
# that character again on restore.
#
# TPM overwrites the plugin on update, so this runs from bootstrap.sh and from
# tmux.conf. It is idempotent — a patched checkout is left alone.

set -euo pipefail

for dir in "$HOME/.config/tmux/plugins/tmux-resurrect" "$HOME/.tmux/plugins/tmux-resurrect"; do
  save="$dir/scripts/save.sh"
  restore="$dir/scripts/restore.sh"
  [ -f "$save" ] && [ -f "$restore" ] || continue

  if ! grep -q 'format+="#{pane_title}"' "$save"; then
    continue # already patched, or upstream changed and the patch needs a look
  fi

  # Save the title with a ":" guard so the empty case still occupies a column.
  sed -i.bak 's/format+="#{pane_title}"/format+=":#{pane_title}"/' "$save"

  # Drop the guard again before the title is handed back to tmux.
  sed -i.bak 's|^\t\tdir="$(remove_first_char "$dir")"$|\t\tdir="$(remove_first_char "$dir")"\n\t\tpane_title="$(remove_first_char "$pane_title")"|' "$restore"

  rm -f "$save.bak" "$restore.bak"
  echo "==> Patched tmux-resurrect (empty pane title dropped the cwd) in $dir"
done
