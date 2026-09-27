---
name: tidy-notes
description: Tidy the research docs. Compress idea.md and move old log entries to docs/research/archive, as a proposal; after approval, apply it and commit it to the notes repo.
argument-hint: "[number of recent entries to keep (default 10)]"
disable-model-invocation: true
allowed-tools:
  - Bash(wc -l docs/research/*)
  - Read
  - Glob
  - Grep
---
Tidy the research docs to prevent context bloat and stale information.

If `docs/research/` does not exist, tell the user to run `/research-init` first and stop. The only git commands allowed on `docs/research/` are the `add` and `commit` in the final step. Never push.

Number of recent entries to keep: $ARGUMENTS (default 10 if empty)

## Steps
1. Run `wc -l docs/research/*.md` to see which files have grown.
2. `idea.md`: find duplication, stale statements, and history-like text already covered in `decisions.md`, and propose a **compressed version**. Reduce `[rejected]` items to one line plus the reference ID.
3. `decisions.md`, `experiments.md`: propose moving all but the most recent N entries to `archive/decisions-YYYY-MM.md` and `archive/experiments-YYYY-MM.md` (by entry date). Keep any entry still referenced by `idea.md` or an open question.
4. `open_questions.md`: propose moving `resolved` entries to the archive.
5. **Do not change meaning.** Only move or compress; never delete information.
6. Stop and wait. After explicit approval, apply the changes.
7. Commit immediately, listing every modified file and every new archive file explicitly:
   `git -C docs/research add -- <files> && git -C docs/research commit -m "Tidy notes"`
   Stage only the files you changed in this skill (never `add -A`), so unrelated uncommitted notes are left alone. If the commit fails, report the error and stop; do not try other git commands.
