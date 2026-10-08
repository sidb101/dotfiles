# ~/.zshrc (symlinked from dotfiles). Machine-specific bits go in ~/.zshrc.local.

# Homebrew (Apple Silicon)
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Oh My Zsh (installed by extras/install-ohmyzsh.sh)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="afowler"
plugins=(git)
[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# History — set after Oh My Zsh, which sets smaller defaults
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

export EDITOR=nvim
export VISUAL=nvim

alias unquarantine='xattr -d com.apple.quarantine'

# fzf: Ctrl-R history search, Ctrl-T file picker, Alt-C cd (fzf 0.48+)
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)

# NVM (only if installed)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# plog: log a tmux pane to ~/.tmux-logs/<name>.log (see shell/tmuxlog.zsh).
# :A resolves the ~/.zshrc symlink, so this finds the repo wherever it is cloned.
[[ -r "${${(%):-%x}:A:h}/shell/tmuxlog.zsh" ]] && source "${${(%):-%x}:A:h}/shell/tmuxlog.zsh"

# Machine-specific settings (work aliases, PATH additions, secrets): not tracked
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"


## PATH
export PATH="$PATH:/Users/siddharth/Software/kafka_2.13-3.5.0/bin"
export PATH="$PATH:/usr/local/mongodb/bin"
export PATH="$PATH:/Users/siddharth/Software/spark-3.4.1-bin-hadoop3/bin"
export PATH="$HOME/.local/bin:$PATH"

## Java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home

## Big data
export AIRFLOW_HOME=~/Software/airflow
export SPARK_HOME=/Users/siddharth/Software/spark-3.4.1-bin-hadoop3

source ~/.bash_profile
source $ZSH/oh-my-zsh.sh

## rbenv (Ruby version manager — puts shims ahead of system Ruby)
eval "$(rbenv init - zsh)"

