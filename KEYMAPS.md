# Keymaps

Bindings marked **★** are defined in this repo. The rest are upstream defaults,
listed here only because they are the ones worth remembering — they are not
exhaustive.

## Tmux

Prefix is `Ctrl+A`. Pressing it opens a menu of the keys below, so the table
is only here for reference — the menu is the source of truth and lives in
`.config/tmux/prefix-menu.conf`. `Space` turns to a second page
(`prefix-menu-more.conf`) with the stock bindings worth a hint; `Space` again
drops into the plain prefix table with every tmux default. On a terminal too
short for the menu, `Ctrl+A` goes straight to that table.

| Key | Action |
|-----|--------|
| `Ctrl+A` | Prefix — opens the hint menu ★ |
| `Prefix + Space` | Second menu page; `Space` again for the plain prefix table ★ |
| `Prefix + Ctrl+A` | Send a literal Ctrl+A to the app ★ |
| `Prefix + \|` | Split pane **horizontal** ★ |
| `Prefix + -` | Split pane **vertical** ★ |
| `Prefix + r` | Reload tmux config ★ |
| `Prefix + m` | Toggle pane zoom ★ |
| `Prefix + T` | Toggle dark/light theme ★ |
| `Prefix + P` | Paste from the system clipboard ★ |
| `Prefix + h/j/k/l` | Resize pane (repeatable) ★ |
| `Prefix + x` | Kill pane |
| `Prefix + c` / `,` / `n` / `p` / `w` | New / rename / next / previous / choose window |
| `Prefix + s` / `d` | Choose session / detach |
| `Ctrl+h/j/k/l` | Navigate panes, no prefix — crosses into Neovim splits ★ |
| `Ctrl+\` | Toggle last pane, no prefix ★ |
| `Prefix + Space q` | Show pane numbers |
| `Prefix + Space t` | Clock |
| `Prefix + Space I` | Install TPM plugins |
| `Prefix + Space U` | Update TPM plugins |
| **Copy mode** (`Prefix + [`) | |
| `v` | Start selection ★ |
| `y` | Yank to clipboard ★ |

## Neovim (LazyVim)

| Key | Mode | Action |
|-----|------|--------|
| `Space` | — | Leader key |
| `jj` | Insert | Exit insert mode ★ |
| `jj` | Terminal | Exit terminal mode ★ |
| `Ctrl+h/j/k/l` | Normal | Move between splits, and out into tmux panes ★ |
| `Ctrl+\` | Normal | Move to the previous split or tmux pane ★ |
| `<leader>ut` | Normal | Toggle dark/light theme ★ |
| `<leader>e` | Normal | File explorer |
| `<leader>ff` | Normal | Find files |
| `<leader>fg` | Normal | Find files (git-tracked only) |
| `<leader>fr` | Normal | Recent files |
| `<leader>fb` | Normal | Buffer list |
| `<leader>sg` | Normal | Live grep |
| `<leader>sw` | Normal | Grep word under cursor |
| `<leader>sk` | Normal | Search keymaps |
| `<leader>su` | Normal | Undo tree |
| `<leader>gs` | Normal | Git status |
| `<leader>gd` | Normal | Git diff (hunks) |
| `<leader>uC` | Normal | Pick a colorscheme |
| `]d` / `[d` | Normal | Next / previous diagnostic |
| `gd` / `gr` | Normal | Go to definition / references (once an LSP attaches) |
| `K` | Normal | Hover documentation (once an LSP attaches) |

Split and pane navigation is one flat grid: `Ctrl+h/j/k/l` moves between
Neovim splits and keeps going into the surrounding tmux panes once the cursor
reaches the edge. It takes both halves — the `is_vim` bindings in
`.config/tmux/tmux.conf` forward the key into Neovim, and vim-tmux-navigator
decides whether to move a split or hand the key back to tmux. Remove either
half and the key dead-ends inside Neovim.

`<leader>sk` lists every active mapping, which beats keeping a longer table here
in sync. For upstream defaults see `:help lazyvim-keymaps`.

## Shell

The shell has no keybinding for this — it is a command, because switching
theme re-execs zsh and that is not something to trigger by a stray keypress.

| Command | Action |
|---------|--------|
| `theme` | Toggle dark/light theme ★ |
| `theme light` / `theme dark` | Switch to a specific mode ★ |

## Theme toggles at a glance

Each tool keeps its own mode; they are deliberately not wired together.

| Tool | How |
|------|-----|
| Neovim | `<leader>ut` |
| Tmux | `Prefix + T` |
| Zsh | `theme` |
| Claude Code | `/config` → Theme |
