#!/usr/bin/env bash
# install-ohmyzsh.sh — install Oh My Zsh if it's missing.
#
# The theme (afowler) and plugins are set in this repo's .zshrc, so the
# installer must NOT overwrite ~/.zshrc (KEEP_ZSHRC=yes). Idempotent.

set -euo pipefail

if [[ -d "$HOME/.oh-my-zsh" ]]; then
  echo "Oh My Zsh already installed at ~/.oh-my-zsh — nothing to do."
  exit 0
fi

echo "Installing Oh My Zsh..."
RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
  "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
  "" --unattended

echo "Done. Open a new shell (the repo's .zshrc selects the theme and plugins)."
