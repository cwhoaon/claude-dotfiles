#!/usr/bin/env bash
# Deterministic part of /research-init.
# usage: init.sh <project-dir> [notes-repo-url]
# Never overwrites existing files. Safe to run multiple times.
# Does NOT touch CLAUDE.md (Claude merges that) and never commits in the parent repo.
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATES="$SKILL_DIR/templates/docs"
PROJECT_DIR="${1:-.}"
NOTES_URL="${2:-}"
NOTES_REL="docs/research"

if ! ROOT="$(git -C "$PROJECT_DIR" rev-parse --show-toplevel 2>/dev/null)"; then
  echo "ERROR: $PROJECT_DIR is not inside a git repo. Run 'git init' first." >&2
  exit 1
fi
cd "$ROOT"
NOTES="$ROOT/$NOTES_REL"
echo "Parent repo: $ROOT"

echo "[1/3] notes repo"
if [ -d "$NOTES/.git" ]; then
  echo "  reuse existing notes repo"
elif [ -n "$NOTES_URL" ]; then
  if [ -e "$NOTES" ] && [ -n "$(ls -A "$NOTES" 2>/dev/null)" ]; then
    echo "ERROR: $NOTES_REL exists and is not empty; cannot clone into it." >&2
    exit 1
  fi
  mkdir -p "$(dirname "$NOTES")"
  git clone "$NOTES_URL" "$NOTES"
else
  mkdir -p "$NOTES"
  git -C "$NOTES" init -q
  git -C "$NOTES" symbolic-ref HEAD refs/heads/main   # works on old and new git
  echo "  initialized local notes repo on branch main (no remote)"
fi

echo "[2/3] docs"
cd "$TEMPLATES"
find . -type f | sort | while read -r rel; do
  rel="${rel#./}"
  dst="$NOTES/$rel"
  if [ -e "$dst" ]; then
    echo "  skip (exists): $NOTES_REL/$rel"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$rel" "$dst"
    echo "  created:       $NOTES_REL/$rel"
  fi
done
cd "$ROOT"

echo "[3/3] .gitignore"
touch .gitignore
if grep -qxF "$NOTES_REL/" .gitignore; then
  echo "  skip (exists): $NOTES_REL/ entry"
else
  printf '\n# research notes (separate private repo)\n%s/\n' "$NOTES_REL" >> .gitignore
  echo "  appended:      $NOTES_REL/"
fi

if ! git -C "$NOTES" rev-parse --verify -q HEAD >/dev/null; then
  git -C "$NOTES" add -A
  git -C "$NOTES" commit -q -m "Initialize research notes"
  echo "  notes repo: initial commit"
fi

echo "OK"
