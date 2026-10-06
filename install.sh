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
# Optional extras (run separately): extras/install-ohmyzsh.sh,
# extras/install-iterm2.sh, and `brew bundle` for the Brewfile.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ts=$(date +%Y%m%d_%H%M%S)

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

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo
  echo "==> Oh My Zsh isn't installed: run $DOTFILES_DIR/extras/install-ohmyzsh.sh"
fi
if [[ -e "$HOME/.zshrc.bak.$ts" ]]; then
  echo
  echo "==> Your previous ~/.zshrc was saved as ~/.zshrc.bak.$ts."
  echo "    Move anything machine-specific from it into ~/.zshrc.local (sourced at the end of .zshrc)."
fi

echo
echo "Done. Next: tmux new -s work   (the first nvim launch installs the Tokyo Night theme)"
echo "Optional: $DOTFILES_DIR/extras/install-iterm2.sh"
