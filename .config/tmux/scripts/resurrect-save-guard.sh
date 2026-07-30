#!/usr/bin/env bash
# Wrapper aman untuk tmux-resurrect save.sh.
#
# Kenapa perlu: save.sh yang dijalankan saat server tmux SUDAH mati tetap bikin
# file save baru — tapi isinya 0 byte — lalu meng-update symlink `last` ke situ.
# Restore berikutnya jadi mengembalikan "tidak ada apa-apa", alias semua session
# hilang. Ini gampang kejadian di ExecStop unit systemd waktu shutdown, karena
# server bisa saja sudah keburu dibunuh sebelum ExecStop sempat jalan.
#
# Guard di sini: kalau ga ada server/session hidup, jangan save sama sekali —
# biarkan save valid yang terakhir tetap jadi `last`.

set -u

RESURRECT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect"
SAVE_SCRIPT="${HOME}/.config/tmux/plugins/tmux-resurrect/scripts/save.sh"

tmux has-session >/dev/null 2>&1 || exit 0
[ -x "$SAVE_SCRIPT" ] || exit 0

"$SAVE_SCRIPT" quiet

# Sabuk pengaman kedua: kalau save barusan ternyata tetap kosong, buang dan
# balikkan `last` ke file save valid terakhir.
last_file="$(readlink -f "${RESURRECT_DIR}/last" 2>/dev/null || true)"
if [ -n "$last_file" ] && [ -f "$last_file" ] && [ ! -s "$last_file" ]; then
	rm -f "$last_file"
	newest_valid="$(find "$RESURRECT_DIR" -maxdepth 1 -name 'tmux_resurrect_*.txt' -size +0c \
		-printf '%f\n' 2>/dev/null | sort | tail -1)"
	[ -n "$newest_valid" ] && ln -sfn "$newest_valid" "${RESURRECT_DIR}/last"
fi
