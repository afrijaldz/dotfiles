# CLAUDE.md

Guidance for working in this dotfiles repo.

## Language

Write everything in **English**. This applies to code comments, notes, hints,
commit messages, documentation, and any prose in config files or scripts. Keep
existing content English too — if you touch a file that has comments in another
language, translate them to English as part of the change.

## This repo is public

Treat everything here as world-readable. Keep personal and work specifics out of
tracked files — no employer or client names, no internal project or repo names,
no absolute paths into private notes, no details about what is or isn't backed
up. Anything a script needs along those lines belongs in a machine-local config
file outside this repo, with only a placeholder example committed here.

`.claude/hooks/daily-recap.py` is the pattern to follow: the script is generic
and reads `~/.config/daily-recap.json`, which is not tracked. Without that file
the hook is inert.

## The daily recap hook is meant to be on

If it looks disabled — no `SessionStart` entry in `~/.claude/settings.json`, or
`~/.claude/hooks` missing — the user wants it back on, and `./bootstrap.sh`
restores both. It is not tied to a Claude account, so switching accounts is
never the cause. A missing machine-local config is the other possibility.

Read the "Daily recap" section of README.md before changing the write path; it
is deliberately narrow because the notes it writes into may have no version
history.
