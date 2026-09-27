---
name: sync-out
description: End of session. Reflect this session's research-context changes in docs/research as a proposed diff; after approval, apply it and commit it to the notes repo.
argument-hint: "[extra notes to include (optional)]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
---
Reflect the research-context changes from this session into `docs/research/`.

If `docs/research/` does not exist, tell the user to run `/research-init` first and stop. The only git commands allowed on `docs/research/` are the `add` and `commit` in the final step. Never push.

Extra notes: $ARGUMENTS

## Steps
1. Review the whole conversation and extract:
   - New **decisions**, their rationale, and rejected alternatives
   - Hypothesis status changes (`[hypothesis]` → `[confirmed]`/`[rejected]`, new hypotheses)
   - Changes in method or priorities
   - New questions and resolved questions
   - Experiment results not yet recorded (if any, recommend `/log-exp`)
2. **Do not include anything that was not actually agreed on in the conversation.** If unclear, list it under "Needs confirmation" and ask.
3. Show proposed changes per file as a unified diff:
   - `idea.md`: **rewrite to the current state** (no accumulated history) and update "Last updated"
   - `decisions.md`: **append** new D-NNN entries
   - `open_questions.md`: add entries / change status
4. If there is nothing to change, say "No changes to reflect" and stop.
5. Stop and wait. Apply only the parts the user explicitly approves.
6. Commit immediately, listing the changed files explicitly:
   `git -C docs/research add -- <changed files> && git -C docs/research commit -m "Sync: <one-line summary>"`
   Stage only the files you changed in this skill (never `add -A`), so unrelated uncommitted notes are left alone. If the commit fails, report the error and stop; do not try other git commands.
