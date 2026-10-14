#!/usr/bin/env bash
# install-iterm2-colors.sh — import the Tokyo Night Day / Night colour presets
# into iTerm2's Color Presets list.
#
# iterm2/Sid.json already carries these colours (Day in light mode, Night in
# dark mode), so the dynamic profile needs nothing from this script. Use it when
# you want the same presets for another profile, or on a machine where the
# profile in use isn't the dynamic one: iTerm2 can't assign a preset from
# outside the app, so after the import you pick them once in
#   Settings → Profiles → (profile) → Colors → Light / Dark → Color Presets…
#
# The presets are tokyonight.nvim's extras/iterm/*.itermcolors, which Neovim's
# vim.pack installs the first time nvim/init.lua runs, so start nvim once first.
# TOKYONIGHT_ITERM_DIR can point at a different directory of .itermcolors files.

set -euo pipefail

DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
SRC="${TOKYONIGHT_ITERM_DIR:-$DATA_HOME/nvim/site/pack/core/opt/tokyonight.nvim/extras/iterm}"
DAY="$SRC/tokyonight_day.itermcolors"
NIGHT="$SRC/tokyonight_night.itermcolors"

for f in "$DAY" "$NIGHT"; do
  if [[ ! -f "$f" ]]; then
    echo "Not found: $f" >&2
    echo "Start nvim once so vim.pack installs tokyonight.nvim, then re-run." >&2
    exit 1
  fi
done

if [[ ! -d "/Applications/iTerm.app" ]]; then
  echo "iTerm2 is not installed; run extras/install-iterm2.sh first." >&2
  exit 1
fi

echo "Importing tokyonight_day and tokyonight_night into iTerm2..."
open -a iTerm "$DAY" "$NIGHT"

cat <<'MSG'

The presets are imported. To use them in a profile:
  iTerm2 → Settings → Profiles → (your profile) → Colors
    • Light / Dark toggle at the top: Light → Color Presets… → tokyonight_day
    • Light / Dark toggle at the top: Dark  → Color Presets… → tokyonight_night
(The profile needs "Use separate colors for light and dark mode" enabled; the
dynamic profile from iterm2/Sid.json already has it, and its colours are set.)
MSG
