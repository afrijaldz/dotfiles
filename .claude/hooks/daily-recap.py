#!/usr/bin/env python3
"""Daily activity recap into a Markdown notes folder.

Collects what was worked on for a given day and writes it into that day's note.
Two sources, both cheap and already summarized:

  - git commits authored by the user, across every repo under $HOME
  - Claude Code session titles (the `aiTitle` entries in ~/.claude/projects)

Everything specific to one person — where the notes live, how work is split
between folders, what language the notes are written in — comes from a config
file outside this repo. Without that config the hook stays silent, so this is
inert until someone points it at their own notes.

Config: $DAILY_RECAP_CONFIG, or ~/.config/daily-recap.json

    {
      "notes_dir": "~/notes",           // required
      "default_folder": "Daily",        // subfolder for unrouted work
      "language": "English",            // language to write the recap in
      "lookback_days": 7,
      "routes": [                       // optional, first match wins
        { "name": "work", "path": "~/src/acme", "folder": "Projects/Acme/daily" }
      ]
    }

A route sends work done under `path` to `folder` instead of the default one.
`name` is what you pass to `write` as the bucket.

Notes folders often have no version history, so all file surgery lives here
rather than being re-derived by a model each run:

  - a note is only ever appended to, inside one marked block
  - that block is the only region ever rewritten; handwritten notes above it are
    never touched
  - the daily filename is matched with either one or two spaces before a new one
    is created, since both spellings tend to exist side by side

Commands:
  pending           list days that have activity but no recap yet (JSON)
  collect <date>    raw material for one day (JSON)
  write <date> <bucket>
                    insert the recap block, prose read from stdin
  hook              SessionStart hook entry point; silent when nothing is due
"""

import json
import os
import re
import subprocess
import sys
from datetime import date, timedelta
from pathlib import Path

HOME = Path.home()
SESSIONS_ROOT = HOME / ".claude/projects"
CONFIG_PATH = Path(
    os.environ.get("DAILY_RECAP_CONFIG", HOME / ".config/daily-recap.json")
)

DEFAULT_BUCKET = "default"
BLOCK_START = "<!-- daily-recap:{d} -->"
BLOCK_END = "<!-- /daily-recap -->"
BLOCK_RE = re.compile(
    r"\n*<!-- daily-recap:\d{4}-\d{2}-\d{2} -->.*?<!-- /daily-recap -->",
    re.DOTALL,
)

# Repos sit at ~/<repo> and ~/<group>/<sub>/<repo>, so 4 is deep enough.
# Skipped trees are large and never interesting.
SCAN_DEPTH = 4
SKIP_PARTS = {".oh-my-zsh", ".nvm", "node_modules", ".cache", ".local", "jobs"}


def load_config():
    """Machine-local settings, or None when this machine has none."""
    if not CONFIG_PATH.exists():
        return None
    try:
        with open(CONFIG_PATH) as f:
            cfg = json.load(f)
    except (ValueError, OSError):
        return None
    if not cfg.get("notes_dir"):
        return None

    cfg["notes_dir"] = Path(cfg["notes_dir"]).expanduser()
    cfg.setdefault("default_folder", "Daily")
    cfg.setdefault("language", "English")
    cfg.setdefault("lookback_days", 7)
    routes = []
    for r in cfg.get("routes", []):
        if r.get("name") and r.get("path") and r.get("folder"):
            routes.append({
                "name": r["name"],
                "path": Path(r["path"]).expanduser(),
                "folder": r["folder"],
            })
    cfg["routes"] = routes
    return cfg


def buckets(cfg):
    return [DEFAULT_BUCKET] + [r["name"] for r in cfg["routes"]]


def run(cmd, cwd=None):
    try:
        p = subprocess.run(
            cmd, cwd=cwd, capture_output=True, text=True, timeout=20, check=False
        )
        return p.stdout.strip()
    except (subprocess.TimeoutExpired, OSError):
        return ""


def git_email():
    return run(["git", "config", "user.email"]) or ""


def find_repos():
    repos = []
    for depth in range(1, SCAN_DEPTH + 1):
        for git_dir in HOME.glob("/".join(["*"] * depth) + "/.git"):
            repo = git_dir.parent
            if SKIP_PARTS & set(repo.parts):
                continue
            repos.append(repo)
    return sorted(set(repos))


def bucket_for(cfg, path):
    """Which bucket a path belongs to. First matching route wins."""
    if not path:
        return DEFAULT_BUCKET
    for r in cfg["routes"]:
        try:
            Path(path).relative_to(r["path"])
            return r["name"]
        except ValueError:
            continue
    return DEFAULT_BUCKET


def collect_range(cfg, days):
    """Everything that happened across `days`, keyed by date then bucket.

    One pass over the repos and one over the session logs, not one per day:
    this runs on every session start, and re-scanning per day made it several
    times slower for no extra information.
    """
    days = sorted(days)
    wanted = {str(d) for d in days}
    start = f"{days[0]} 00:00:00"
    end = f"{days[-1] + timedelta(days=1)} 00:00:00"
    email = git_email()
    names = buckets(cfg)

    out = {
        str(d): dict(
            {"date": str(d)},
            **{b: {"commits": [], "sessions": []} for b in names},
        )
        for d in days
    }

    for repo in find_repos():
        log = run(
            [
                "git", "log",
                f"--since={start}", f"--until={end}",
                f"--author={email}",
                "--format=%cs\x1f%h\x1f%s",
                "--no-merges",
            ],
            cwd=repo,
        )
        if not log:
            continue
        bucket = bucket_for(cfg, repo)
        for line in log.splitlines():
            cdate, _, rest = line.partition("\x1f")
            sha, _, subject = rest.partition("\x1f")
            if cdate in wanted:
                out[cdate][bucket]["commits"].append(
                    {"repo": repo.name, "sha": sha, "subject": subject}
                )

    if SESSIONS_ROOT.exists():
        for f in sorted(SESSIONS_ROOT.glob("*/*.jsonl")):
            title, cwd, seen = None, None, set()
            try:
                with open(f, errors="ignore") as fh:
                    for line in fh:
                        try:
                            o = json.loads(line)
                        except ValueError:
                            continue
                        ts = o.get("timestamp")
                        if ts and ts[:10] in wanted:
                            seen.add(ts[:10])
                        if o.get("type") == "ai-title" and o.get("aiTitle"):
                            title = o["aiTitle"]
                        if o.get("cwd") and not cwd:
                            cwd = o["cwd"]
            except OSError:
                continue
            if title:
                bucket = bucket_for(cfg, cwd)
                for d in seen:
                    out[d][bucket]["sessions"].append(
                        {"title": title, "cwd": cwd or ""}
                    )

    for day in out.values():
        for b in names:
            seen_titles = set()
            uniq = []
            for s in day[b]["sessions"]:
                if s["title"] not in seen_titles:
                    seen_titles.add(s["title"])
                    uniq.append(s)
            day[b]["sessions"] = uniq
    return out


def collect(cfg, day):
    return collect_range(cfg, [day])[str(day)]


def has_activity(data, bucket):
    return bool(data[bucket]["commits"] or data[bucket]["sessions"])


def note_path(cfg, day, bucket):
    """Existing note for the day, or where a new one should go.

    Daily filenames tend to exist with both one and two spaces between the date
    and the day name; match either so a second note is never created alongside
    one that is already there.
    """
    folder = cfg["default_folder"]
    for r in cfg["routes"]:
        if r["name"] == bucket:
            folder = r["folder"]
            break
    base = cfg["notes_dir"] / folder
    dayname = day.strftime("%A")
    for sep in ("  ", " "):
        p = base / f"{day}{sep}{dayname}.md"
        if p.exists():
            return p
    # Some older names are malformed; still prefer an existing note over a
    # duplicate for the same day.
    for cand in sorted(base.glob(f"{day}*.md")):
        return cand
    return base / f"{day}  {dayname}.md"


def already_recapped(cfg, day, bucket):
    p = note_path(cfg, day, bucket)
    if not p.exists():
        return False
    return BLOCK_START.format(d=day) in p.read_text(errors="ignore")


def pending(cfg, today=None):
    """Days before today that had activity and no recap block yet.

    Today is deliberately excluded: the cut-off is midnight, so a day is only
    written up once it is over.
    """
    today = today or date.today()
    window = [today - timedelta(days=i) for i in range(1, cfg["lookback_days"] + 1)]
    collected = collect_range(cfg, window)
    days = []
    for d in sorted(window):
        data = collected[str(d)]
        due = [b for b in buckets(cfg)
               if has_activity(data, b) and not already_recapped(cfg, d, b)]
        if due:
            days.append({"date": str(d), "buckets": due, "data": data})
    return days


def write(cfg, day, bucket, prose):
    """Insert or replace this day's recap block. Nothing else is modified."""
    p = note_path(cfg, day, bucket)
    p.parent.mkdir(parents=True, exist_ok=True)
    existing = p.read_text(errors="ignore") if p.exists() else ""

    block = "\n\n".join([
        BLOCK_START.format(d=day),
        prose.strip(),
        BLOCK_END,
    ])

    if BLOCK_START.format(d=day) in existing:
        body = BLOCK_RE.sub("\n\n" + block, existing, count=1)
    else:
        body = (existing.rstrip() + "\n\n" + block) if existing.strip() else block
    p.write_text(body.rstrip() + "\n")
    return p


def hook(cfg):
    """SessionStart entry point. Prints nothing when there is nothing to do."""
    try:
        days = pending(cfg)
    except Exception:
        return  # never let a recap failure break a session
    if not days:
        return

    lang = cfg["language"]
    lines = [
        f"Some days have not been recapped into the notes yet. For EACH entry "
        f"below, write a short summary in {lang} (bullet points, focused on what "
        f"was done and what came of it, not a raw commit list), then save it:",
        "",
        "  echo '<summary>' | ~/.claude/hooks/daily-recap.py write <date> <bucket>",
        "",
        "Do not copy any secret value into a summary. Report which files were "
        "written once done.",
        "",
    ]
    for entry in days:
        d = entry["date"]
        for b in entry["buckets"]:
            data = entry["data"][b]
            lines.append(f"## {d} — bucket: {b}")
            for c in data["commits"]:
                lines.append(f"- commit [{c['repo']}] {c['subject']}")
            for s in data["sessions"]:
                lines.append(f"- Claude session: {s['title']}")
            lines.append("")

    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": "\n".join(lines),
        }
    }))


def main():
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        return 1
    cmd = args[0]

    cfg = load_config()
    if cfg is None:
        # Silent for the hook so an unconfigured machine costs nothing; loud for
        # anything invoked by hand, so a broken config isn't mistaken for "no
        # activity today".
        if cmd != "hook":
            print(f"no usable config at {CONFIG_PATH} — see the module docstring",
                  file=sys.stderr)
            return 1
        return 0

    if cmd == "hook":
        hook(cfg)
    elif cmd == "pending":
        print(json.dumps(pending(cfg), indent=2, ensure_ascii=False))
    elif cmd == "collect":
        print(json.dumps(collect(cfg, date.fromisoformat(args[1])),
                         indent=2, ensure_ascii=False))
    elif cmd == "write":
        d = date.fromisoformat(args[1])
        bucket = args[2]
        if bucket not in buckets(cfg):
            print(f"unknown bucket: {bucket} (have: {', '.join(buckets(cfg))})",
                  file=sys.stderr)
            return 1
        prose = sys.stdin.read()
        if not prose.strip():
            print("refusing to write an empty recap", file=sys.stderr)
            return 1
        print(write(cfg, d, bucket, prose))
    else:
        print(f"unknown command: {cmd}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
