#!/usr/bin/env bash
# install-iterm2.sh — install iTerm2 (if missing), then set up the profile and prefs.
#
#   iterm2/Sid.json          -> ~/Library/Application Support/iTerm2/DynamicProfiles/
#                               (iTerm2 loads it automatically; edits to the file
#                               show up live, and the profile is read-only in the GUI)
#   iterm2/global-prefs.plist -> merged into iTerm2's preferences (iterm2/apply-prefs.sh)
#
# Idempotent. Quit iTerm2 before running if you want the global prefs applied.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -d "/Applications/iTerm.app" ]]; then
  if command -v brew >/dev/null 2>&1; then
    echo "==> Installing iTerm2 via Homebrew"
    brew install --cask iterm2
  else
    echo "iTerm2 isn't installed and Homebrew is unavailable." >&2
    echo "Install it from https://iterm2.com/downloads.html and re-run." >&2
    exit 1
  fi
else
  echo "==> iTerm2 already installed"
fi

PROFILES_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
echo "==> Linking the Sid profile into $PROFILES_DIR"
mkdir -p "$PROFILES_DIR"
ln -sfn "$REPO_DIR/iterm2/Sid.json" "$PROFILES_DIR/Sid.json"

echo "==> Applying global preferences (key bindings, tab bar, ...)"
if pgrep -x iTerm2 >/dev/null; then
  echo "    iTerm2 is running — quit it, then run:  $REPO_DIR/iterm2/apply-prefs.sh"
else
  "$REPO_DIR/iterm2/apply-prefs.sh"
fi

cat <<'EOF'

Next: open iTerm2 → Settings → Profiles → "Sid" → Other Actions → Set as Default.
EOF
