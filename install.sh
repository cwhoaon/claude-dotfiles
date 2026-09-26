#!/usr/bin/env bash
# install.sh — symlink claude-dotfiles into ~/.claude
#
# Expected repo layout (every entry is optional):
#   claude-dotfiles/
#   ├── install.sh
#   ├── CLAUDE.md        -> ~/.claude/CLAUDE.md
#   ├── settings.json    -> ~/.claude/settings.json
#   ├── rules/           -> ~/.claude/rules
#   ├── agents/          -> ~/.claude/agents
#   ├── commands/        -> ~/.claude/commands
#   ├── hooks/           -> ~/.claude/hooks
#   ├── skills/<name>/   -> ~/.claude/skills/<name>   (linked one by one)
#   └── vendor/          third-party repos / git submodules (not linked directly;
#                        point skills/<name> at vendor/... with a relative symlink)
#
# Usage:
#   ./install.sh              install / update links
#   ./install.sh --dry-run    show what would happen, change nothing
#   ./install.sh --uninstall  remove links that point into this repo
#
# Existing files are never deleted: they are moved to
#   ~/.claude/backups/dotfiles-<timestamp>/
# Never touched: .credentials.json, projects/, skills/synced/, ~/.claude.json
#
# Respects CLAUDE_CONFIG_DIR if set. Compatible with bash 3.2 (macOS) and Linux.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
BACKUP_DIR="$CLAUDE_DIR/backups/dotfiles-$(date +%Y%m%d-%H%M%S)"

# Top-level items linked as a whole (file or directory).
ITEMS="CLAUDE.md settings.json rules agents commands hooks"

DRY_RUN=0
MODE="install"

for arg in "$@"; do
  case "$arg" in
    -n|--dry-run)   DRY_RUN=1 ;;
    -u|--uninstall) MODE="uninstall" ;;
    -h|--help)      sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $arg (see --help)" >&2; exit 1 ;;
  esac
done

# ---------- helpers ----------
if [ -t 1 ]; then G=$'\033[32m'; Y=$'\033[33m'; B=$'\033[34m'; R=$'\033[0m'; else G=; Y=; B=; R=; fi
info() { printf '%s\n' "${B}==>${R} $*"; }
ok()   { printf '%s\n' "  ${G}✓${R} $*"; }
warn() { printf '%s\n' "  ${Y}!${R} $*"; }

run() {  # run a command, or just print it in dry-run mode
  if [ "$DRY_RUN" -eq 1 ]; then printf '    [dry-run] %s\n' "$*"; else "$@"; fi
}

points_into_repo() {  # true if $1 is a symlink whose target is inside REPO_DIR
  [ -L "$1" ] || return 1
  case "$(readlink "$1")" in "$REPO_DIR"/*) return 0 ;; *) return 1 ;; esac
}

backup() {  # move an existing path aside, preserving its relative location
  local path="$1" rel dest
  rel="${path#"$CLAUDE_DIR"/}"
  dest="$BACKUP_DIR/$rel"
  run mkdir -p "$(dirname "$dest")"
  run mv "$path" "$dest"
  warn "backed up $rel -> ${dest#"$CLAUDE_DIR"/}"
}

link() {  # link <source-in-repo> <destination>
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    ok "${dst#"$CLAUDE_DIR"/} (already linked)"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    backup "$dst"
  fi
  run mkdir -p "$(dirname "$dst")"
  run ln -s "$src" "$dst"
  ok "${dst#"$CLAUDE_DIR"/} -> ${src#"$REPO_DIR"/}"
}

lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

# ---------- uninstall ----------
if [ "$MODE" = "uninstall" ]; then
  info "Removing links into $REPO_DIR from $CLAUDE_DIR"
  for item in $ITEMS; do
    if points_into_repo "$CLAUDE_DIR/$item"; then run rm "$CLAUDE_DIR/$item"; ok "removed $item"; fi
  done
  if [ -d "$CLAUDE_DIR/skills" ]; then
    for dst in "$CLAUDE_DIR"/skills/*; do
      if points_into_repo "$dst"; then run rm "$dst"; ok "removed skills/$(basename "$dst")"; fi
    done
  fi
  info "Done. Backups (if any) are in $CLAUDE_DIR/backups/"
  exit 0
fi

# ---------- install ----------
[ "$DRY_RUN" -eq 1 ] && info "Dry run: nothing will be changed"
info "Repo:   $REPO_DIR"
info "Target: $CLAUDE_DIR"
run mkdir -p "$CLAUDE_DIR"

# 1) Fetch git submodules (third-party skills in vendor/), if any.
if [ -f "$REPO_DIR/.gitmodules" ]; then
  info "Updating git submodules"
  run git -C "$REPO_DIR" submodule update --init --recursive
fi

# 2) Top-level items.
info "Linking top-level items"
for item in $ITEMS; do
  if [ -e "$REPO_DIR/$item" ]; then
    link "$REPO_DIR/$item" "$CLAUDE_DIR/$item"
  fi
done

# 3) Skills, one link per skill so skills/synced/ and local skills are untouched.
if [ -d "$REPO_DIR/skills" ]; then
  info "Linking skills"
  run mkdir -p "$CLAUDE_DIR/skills"
  for src in "$REPO_DIR"/skills/*; do
    [ -e "$src" ] || { [ -L "$src" ] && warn "broken link: skills/$(basename "$src") (submodule not fetched?)"; continue; }
    [ -d "$src" ] || continue
    name="$(basename "$src")"
    if [ "$(lower "$name")" = "synced" ]; then
      warn "skipping skills/$name: 'synced' is reserved for claude.ai sync"
      continue
    fi
    if [ ! -f "$src/SKILL.md" ]; then
      warn "skipping skills/$name: no SKILL.md"
      continue
    fi
    link "$src" "$CLAUDE_DIR/skills/$name"
  done

  # 4) Prune links to skills that were removed from the repo.
  for dst in "$CLAUDE_DIR"/skills/*; do
    if points_into_repo "$dst" && [ ! -e "$dst" ]; then
      run rm "$dst"
      warn "removed stale link skills/$(basename "$dst")"
    fi
  done
fi

# 5) Safety check: make sure no secrets are tracked by git.
if git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  tracked="$(git -C "$REPO_DIR" ls-files | grep -E '(^|/)(\.credentials\.json|\.claude\.json|settings\.local\.json|\.env)$' || true)"
  if [ -n "$tracked" ]; then
    warn "these files look sensitive and are tracked by git:"
    printf '      %s\n' $tracked
  fi
fi

info "Done."
[ -d "$BACKUP_DIR" ] && info "Previous files were backed up to $BACKUP_DIR"
echo "   Verify inside Claude Code with: /context  (memory files) and /skills"
