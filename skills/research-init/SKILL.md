---
name: research-init
description: Set up the research-notes structure (a nested private git repo at docs/research) in the current project.
argument-hint: "[notes-repo-url (optional; omit to create a local repo)]"
disable-model-invocation: true
allowed-tools:
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/init.sh *)
  - Read
  - Edit
  - Write
---
Set up research-sync for this project.

## Hard rules
- Never overwrite an existing file in the project.
- Never commit in the parent repo. Never push anywhere.

## Steps

### 1. Run the setup script
Run exactly:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/init.sh "${CLAUDE_PROJECT_DIR}" $ARGUMENTS
```

It prepares `docs/research/` (clone if a URL was given, otherwise `git init`), copies missing templates from `templates/docs/`, adds `docs/research/` to the parent `.gitignore`, and makes an initial commit in a new notes repo. If it fails, report the error and stop.

### 2. Merge the research block into CLAUDE.md
The block to insert is in [templates/claude-block.md](templates/claude-block.md) (`${CLAUDE_SKILL_DIR}/templates/claude-block.md`). It is delimited by `<!-- research-sync:start -->` and `<!-- research-sync:end -->`.

- **`CLAUDE.md` does not exist**: create it with a short `# Project` section (placeholders for run / test / style), followed by the block.
- **Exists without the start marker**: check whether existing instructions overlap or conflict with the block. If there is a conflict, show it and ask how to resolve before writing. Otherwise append the block at the end.
- **Exists with the marker**: compare the existing block with the template. If identical, skip. If different, show a diff and ask whether to replace it with the template version. Never modify anything outside the markers.

### 3. Report
List what was created and skipped, then the next steps:
1. Fill in `docs/research/idea.md` (offer to draft it from the user's explanation).
2. If there is no remote: `git -C docs/research remote add origin <private-repo-url>` then `git -C docs/research push -u origin main`.
3. Optionally commit `CLAUDE.md` and `.gitignore` in the parent repo.
4. Restart Claude Code so the new `CLAUDE.md` imports load, then run `/sync-in`.
