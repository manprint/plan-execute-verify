#!/usr/bin/env bash
# Symlink this skill into the Claude Code personal skills directory.
# Idempotent: re-running refreshes the link. Removes nothing it didn't create.
set -euo pipefail

SKILL_NAME="plan-execute-verify"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_ROOT="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
DEST="$DEST_ROOT/$SKILL_NAME"

if [[ ! -f "$SRC_DIR/SKILL.md" ]]; then
  echo "error: SKILL.md not found in $SRC_DIR" >&2
  exit 1
fi

mkdir -p "$DEST_ROOT"

if [[ -L "$DEST" ]]; then
  echo "refreshing existing symlink: $DEST"
  rm "$DEST"
elif [[ -e "$DEST" ]]; then
  echo "error: $DEST exists and is not a symlink. Remove it manually first." >&2
  exit 1
fi

ln -s "$SRC_DIR" "$DEST"
echo "installed: $DEST -> $SRC_DIR"
echo "Open Claude Code and ask it to plan a feature, or run /$SKILL_NAME."
