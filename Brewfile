# Install everything with:  brew bundle --file=~/dotfiles/Brewfile

brew "git"
brew "gh"
brew "neovim"   # 0.12+ (nvim/init.lua uses the built-in vim.pack)
brew "tmux"
brew "fzf"
brew "ripgrep"
brew "jq"

# Skip if iTerm2 was installed by hand (avoids a cask conflict)
cask "iterm2" unless File.exist?("/Applications/iTerm.app")
