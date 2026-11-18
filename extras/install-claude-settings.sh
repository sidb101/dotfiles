#!/usr/bin/env bash
# install-claude-settings.sh — merge claude/settings.json into ~/.claude/settings.json.
#
# The repo file wins for the keys it contains; everything else in the live file
# (permissions, which accumulate per machine, MCP servers, ...) is kept. Objects
# merge recursively; arrays such as the hook lists are replaced. The live file is
# backed up before it changes. It's merged rather than symlinked because Claude
# Code rewrites settings.json itself, and that would write machine-specific
# permissions into the repo.
#
# Safe to re-run. Needs jq.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
src="$DOTFILES_DIR/claude/settings.json"
dest="${CLAUDE_DIR:-$HOME/.claude}/settings.json"

if ! command -v jq >/dev/null 2>&1; then
  echo "    [SKIP] jq not installed (brew install jq), so $dest was not touched"
  exit 0
fi

mkdir -p "$(dirname "$dest")"
if [[ ! -e "$dest" ]]; then
  cp "$src" "$dest"
  echo "    [done] created $dest"
  exit 0
fi

if ! jq -e . "$dest" >/dev/null 2>&1; then
  echo "    [SKIP] $dest isn't valid JSON, so it was not touched" >&2
  exit 0
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
jq -s '.[0] * .[1]' "$dest" "$src" > "$tmp"

if [[ "$(jq -S . "$tmp")" == "$(jq -S . "$dest")" ]]; then
  echo "    [ ok ] $dest already current"
else
  backup="$dest.bak.$(date +%Y%m%d_%H%M%S)"
  cp "$dest" "$backup"
  cat "$tmp" > "$dest"
  echo "    [done] merged $src into $dest (backup: $backup)"
fi
