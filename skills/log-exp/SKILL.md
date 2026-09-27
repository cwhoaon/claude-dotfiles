---
name: log-exp
description: Record an experiment in docs/research/experiments.md. Propose the entry first; after approval, append it and commit it to the notes repo.
argument-hint: "[experiment name or short description]"
allowed-tools:
  - Bash(git rev-parse *)
  - Bash(git status *)
  - Read
  - Glob
  - Grep
---
Record the experiment just run in `docs/research/experiments.md`.

If `docs/research/` does not exist, tell the user to run `/research-init` first and stop. The only git commands allowed on `docs/research/` are the `add` and `commit` in the final step. Never push.

Experiment description: $ARGUMENTS

## Steps
1. Run `git rev-parse --short HEAD` and `git status --short` in the parent repo. Use the hash for **Code commit**, and mark `dirty: yes` if the status output is non-empty (ignore `docs/research/`, which is gitignored).
2. Read `docs/research/experiments.md` and determine the next number (EXP-NNN).
3. Fill in the template fields from this conversation and information the user provided.
   - Link the purpose to a hypothesis ID (H*) in `docs/research/idea.md`.
   - **Use only numbers the user provided or that you verified directly in logs/outputs. Never guess; write `TBD` if unknown.**
   - If key fields (results, config) cannot be filled, ask the user first.
4. Show the full entry to be added and state its implication for the hypothesis (supports / contradicts / inconclusive).
5. If this result suggests changing hypothesis tags in `idea.md` or `open_questions.md`, **only propose it** (apply via `/sync-out`).
6. Stop and wait. After the user explicitly approves, append the entry.
7. Commit it immediately:
   `git -C docs/research add -- experiments.md && git -C docs/research commit -m "Log EXP-NNN: <name>"`
   Stage only the files you changed in this skill (never `add -A`), so unrelated uncommitted notes are left alone. If the commit fails, report the error and stop; do not try other git commands.
