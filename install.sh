#!/usr/bin/env bash
# install.sh — symlink these dotfiles into $HOME.
#
#   .vimrc              -> ~/.vimrc                 shared Vim + Neovim settings
#   nvim/init.lua       -> ~/.config/nvim/init.lua  sources ~/.vimrc, adds theme
#   .tmux.conf          -> ~/.tmux.conf
#   .zshrc              -> ~/.zshrc
#   .gitconfig          -> ~/.gitconfig             shared defaults + aliases
#   .gitconfig-personal -> ~/.gitconfig-personal    personal identity (see below)
#   .gitignore_global   -> ~/.gitignore_global
#
# An existing real file is moved to <file>.bak.<timestamp> first, so re-running
# is safe. Exceptions:
#   - A real ~/.gitconfig becomes ~/.gitconfig.local (kept as the machine's
#     default identity/overrides, which .gitconfig includes). On a machine with
#     no ~/.gitconfig, ~/.gitconfig.local is created from .gitconfig-personal.
#   - Neovim refuses to load init.vim next to init.lua, so a stale
#     ~/.config/nvim/init.vim is moved aside.
#
# If iTerm2 is installed, this also runs extras/install-iterm2.sh (links the
# profile, applies the global prefs, makes "Sid" the default profile). iTerm2
# rewrites its preferences when it quits, so the script stops before changing
# anything while iTerm2 is running: quit it and run this from Terminal.app.
# It also installs Oh My Zsh (extras/install-ohmyzsh.sh) when it's missing and
# creates an empty ~/.zshrc.local when there isn't one.
# Re-running is how you update an existing machine after a `git pull`.
#
# Run `brew bundle` for the Brewfile first on a new machine.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ts=$(date +%Y%m%d_%H%M%S)

if pgrep -x iTerm2 >/dev/null 2>&1; then
  cat >&2 <<EOF
iTerm2 is running, and it would overwrite the preferences this script applies.
Quit iTerm2 (Cmd-Q), then run the install again from a terminal that isn't
iTerm2, such as Terminal.app:

  "$DOTFILES_DIR/install.sh"

Nothing has been changed.
EOF
  exit 1
fi

# link <source in repo> <destination>: symlink, backing up a real file first.
link() {
  local src="$1" dest="$2"
  echo "==> Symlinking $dest -> $src"
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "    Backing up existing $dest -> $dest.bak.$ts"
    mv "$dest" "$dest.bak.$ts"
  fi
  ln -sfn "$src" "$dest"
}

link "$DOTFILES_DIR/.vimrc"             "$HOME/.vimrc"
link "$DOTFILES_DIR/.tmux.conf"         "$HOME/.tmux.conf"
link "$DOTFILES_DIR/.zshrc"             "$HOME/.zshrc"
link "$DOTFILES_DIR/.gitignore_global"  "$HOME/.gitignore_global"
link "$DOTFILES_DIR/.gitconfig-personal" "$HOME/.gitconfig-personal"

# git: keep an existing identity as ~/.gitconfig.local instead of losing it
if [[ -e "$HOME/.gitconfig" && ! -L "$HOME/.gitconfig" && ! -e "$HOME/.gitconfig.local" ]]; then
  echo "==> Moving existing ~/.gitconfig -> ~/.gitconfig.local (machine default identity)"
  mv "$HOME/.gitconfig" "$HOME/.gitconfig.local"
elif [[ ! -e "$HOME/.gitconfig" && ! -e "$HOME/.gitconfig.local" ]]; then
  echo "==> Creating ~/.gitconfig.local from .gitconfig-personal (default identity)"
  cp "$DOTFILES_DIR/.gitconfig-personal" "$HOME/.gitconfig.local"
fi
link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

nvim_vim="$HOME/.config/nvim/init.vim"
if [[ -e "$nvim_vim" || -L "$nvim_vim" ]]; then
  echo "==> Moving $nvim_vim aside (conflicts with init.lua) -> $nvim_vim.bak.$ts"
  mv "$nvim_vim" "$nvim_vim.bak.$ts"
fi
link "$DOTFILES_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua"

# Machine-specific shell settings: .zshrc sources this last. Never overwritten.
if [[ ! -e "$HOME/.zshrc.local" ]]; then
  echo "==> Creating ~/.zshrc.local (machine-specific shell settings)"
  cat > "$HOME/.zshrc.local" <<'EOF'
# ~/.zshrc.local — machine-specific shell settings, sourced last by ~/.zshrc.
# Not tracked by the dotfiles repo. .zshrc.local.example in the repo shows the
# kind of thing that goes here (tool PATHs, JAVA_HOME, rbenv).
EOF
fi

echo
echo "==> Checking tools..."
check() {
  if command -v "$1" >/dev/null 2>&1; then
    printf "    [ ok ] %s\n" "$1"
  else
    printf "    [MISS] %s — %s\n" "$1" "$2"
  fi
}
check git  "xcode-select --install"
check nvim "brew install neovim    (0.12+ needed for the built-in plugin manager)"
check tmux "brew install tmux      (3.2+; see tmux-cheatsheet.md)"
check fzf  "brew install fzf       (Ctrl-R / Ctrl-T in the shell)"
echo "    Everything at once:  brew bundle --file=\"$DOTFILES_DIR/Brewfile\""

echo
echo "==> Oh My Zsh"
"$DOTFILES_DIR/extras/install-ohmyzsh.sh"
if [[ -e "$HOME/.zshrc.bak.$ts" ]]; then
  echo
  echo "==> Your previous ~/.zshrc was saved as ~/.zshrc.bak.$ts."
  echo "    Move anything machine-specific from it into ~/.zshrc.local (sourced at the end of .zshrc)."
fi

echo
if [[ -d "/Applications/iTerm.app" ]]; then
  "$DOTFILES_DIR/extras/install-iterm2.sh"
else
  echo "==> iTerm2 isn't installed: brew bundle installs it, then re-run this script."
fi

echo
echo "Done. Next: tmux new -s work   (the first nvim launch installs the Tokyo Night theme)"
