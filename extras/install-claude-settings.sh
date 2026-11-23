#!/usr/bin/env bash
# install-claude-settings.sh — apply the tracked Claude Code config to this machine.
#
#   claude/settings.json      merged into ~/.claude/settings.json
#   claude/global-config.json merged into ~/.claude.json  (keys Claude Code only
#                             reads from there, e.g. leftArrowOpensAgents; it
#                             ignores them in settings.json)
#
# The repo's keys win; everything else in the live file (permissions, which
# accumulate per machine, MCP servers, account state, ...) is kept. Objects merge
# recursively; arrays such as the hook lists are replaced. A live file is backed
# up before it changes. Merged rather than symlinked because Claude Code rewrites
# both files itself, and that would write machine-specific data into the repo.
#
# Safe to re-run. Needs jq.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v jq >/dev/null 2>&1; then
  echo "    [SKIP] jq not installed (brew install jq), so the Claude Code config was not touched"
  exit 0
fi

# merge_json <repo file> <live file>
merge_json() {
  local src="$1" dest="$2" tmp backup
  if [[ ! -e "$dest" ]]; then
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "    [done] created $dest"
    return
  fi
  if ! jq -e . "$dest" >/dev/null 2>&1; then
    echo "    [SKIP] $dest isn't valid JSON, so it was not touched" >&2
    return
  fi
  tmp="$(mktemp)"
  jq -s '.[0] * .[1]' "$dest" "$src" > "$tmp"
  if [[ "$(jq -S . "$tmp")" == "$(jq -S . "$dest")" ]]; then
    echo "    [ ok ] $dest already current"
  else
    backup="$dest.bak.$(date +%Y%m%d_%H%M%S)"
    cp -p "$dest" "$backup"
    cat "$tmp" > "$dest"   # in place, so the file keeps its permissions
    echo "    [done] merged $src into $dest (backup: $backup)"
  fi
  rm -f "$tmp"
}

merge_json "$DOTFILES_DIR/claude/settings.json"      "${CLAUDE_DIR:-$HOME/.claude}/settings.json"
merge_json "$DOTFILES_DIR/claude/global-config.json" "${CLAUDE_GLOBAL_CONFIG:-$HOME/.claude.json}"
