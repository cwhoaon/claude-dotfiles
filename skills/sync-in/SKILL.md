---
name: sync-in
description: Start of session. Read the research docs and summarize current understanding so the user can confirm sync.
argument-hint: "[topic to focus on this session (optional)]"
allowed-tools:
  - Read
  - Glob
  - Grep
---
Synchronize research context. **Do not modify any file in this skill.**

If `docs/research/` does not exist, tell the user to run `/research-init` first and stop. Do not run any git command on `docs/research/`; the user commits notes manually.

## Steps
1. Read `docs/research/idea.md` and `docs/research/open_questions.md`.
2. Read only the **last 3 entries** of `docs/research/decisions.md` and `docs/research/experiments.md`.
3. Summarize briefly in the format below.

## Output format
- **Research goal** (one line)
- **Current hypotheses**: distinguish `[confirmed]` and `[hypothesis]`
- **Recent decisions**: 1–3 recent decisions and their rationale
- **Recent experiments**: result of the last experiment and its next action
- **Open questions**: the highest-priority ones
- **Inconsistencies / uncertainties**: conflicts between docs, stale-looking content, places where code and docs seem to diverge
- **Suggested plan for this session**: 1–3 next steps

Focus topic (if any): $ARGUMENTS

End by asking "Does this match your current understanding?" and stop.
