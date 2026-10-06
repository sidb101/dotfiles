#!/usr/bin/env bash
# apply-prefs.sh — merge iterm2/global-prefs.plist into iTerm2's preferences.
#
# Only the keys listed in global-prefs.plist are touched (global key bindings
# such as Cmd-] / Cmd-[ for next/previous pane, tab bar and pane options, ...);
# every other iTerm2 preference is preserved.
#
# iTerm2 rewrites its preferences when it quits, so quit it first.
# ITERM_DOMAIN can point at a plist file instead (used for testing).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOMAIN="${ITERM_DOMAIN:-com.googlecode.iterm2}"

if [[ -z "${ITERM_DOMAIN:-}" ]] && pgrep -x iTerm2 >/dev/null; then
  echo "Quit iTerm2 first (it overwrites its preferences on quit), then re-run:" >&2
  echo "  $SCRIPT_DIR/apply-prefs.sh" >&2
  exit 1
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

defaults export "$DOMAIN" "$tmp/current.plist" 2>/dev/null || true

python3 - "$tmp/current.plist" "$SCRIPT_DIR/global-prefs.plist" "$tmp/merged.plist" <<'PY'
import os, plistlib, sys
cur_path, new_path, out_path = sys.argv[1:4]
cur = {}
if os.path.exists(cur_path) and os.path.getsize(cur_path) > 0:
    with open(cur_path, "rb") as f:
        cur = plistlib.load(f)
with open(new_path, "rb") as f:
    new = plistlib.load(f)
cur.update(new)
with open(out_path, "wb") as f:
    plistlib.dump(cur, f)
print(f"Merged {len(new)} iTerm2 preference keys.")
PY

defaults import "$DOMAIN" "$tmp/merged.plist"
echo "Done. Start iTerm2 again."
