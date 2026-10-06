# dotfiles

My editor, terminal, and shell setup: Neovim/Vim, tmux, zsh (Oh My Zsh), git, and iTerm2. macOS-oriented.

## Install

```bash
git clone git@github.com:sidb101/dotfiles.git ~/dotfiles
cd ~/dotfiles
brew bundle                              # optional: install the tools below
./install.sh                             # symlink the config files
./extras/install-ohmyzsh.sh              # optional
./extras/install-iterm2.sh               # optional (quit iTerm2 first)
```

`install.sh` symlinks the files below into `$HOME`. Existing real files are backed up as `<file>.bak.<timestamp>`, and re-running is safe.

## Layout

```
dotfiles/
  install.sh              # symlinks everything, checks tools
  Brewfile                # git, gh, neovim, tmux, fzf, ripgrep, jq, iTerm2
  .vimrc                  # shared Vim + Neovim settings (Neovim sources it)
  nvim/init.lua           # Neovim entrypoint: sources ~/.vimrc, adds Tokyo Night
  .tmux.conf              # tmux config
  tmux-cheatsheet.md      # tmux keys and workflow
  .zshrc                  # Oh My Zsh (afowler), history, fzf, nvm, EDITOR=nvim
  .gitconfig              # shared git defaults and aliases (no identity)
  .gitconfig-personal     # personal identity (GitHub noreply address)
  .gitignore_global       # .DS_Store, swap files, ...
  iterm2/
    Sid.json              # iTerm2 profile (loaded as a Dynamic Profile)
    global-prefs.plist    # curated global prefs: key bindings, tab bar, ...
    apply-prefs.sh        # merges global-prefs.plist into iTerm2's preferences
  extras/
    install-ohmyzsh.sh    # installs Oh My Zsh without touching ~/.zshrc
    install-iterm2.sh     # installs iTerm2, links the profile, applies prefs
```

## What you get

- **Vim / Neovim** (`.vimrc`): absolute + relative line numbers, 80-column guide, `autoread` (picks up edits made by other programs), and a tidier `netrw` file explorer (25% sidebar, tree view, opens files in the previous window).
- **Neovim only** (`nvim/init.lua`): installs [Tokyo Night](https://github.com/folke/tokyonight.nvim) (night style) with Neovim's built-in `vim.pack`, so there's no plugin-manager bootstrap. Falls back to the `.vimrc` colorscheme if the plugin isn't available. Needs Neovim 0.12+.
- **tmux** (`.tmux.conf`): mouse support, windows numbered from 1, splits and new windows open in the current directory, true color, drag-to-copy to the macOS clipboard (`pbcopy`), `Shift-Enter` passthrough (`extended-keys`), and a higher-contrast status bar. Needs tmux 3.2+. Keys are in [`tmux-cheatsheet.md`](tmux-cheatsheet.md).
- **zsh** (`.zshrc`): Oh My Zsh with the `afowler` theme, 100k-line history, `fzf` key bindings (Ctrl-R, Ctrl-T, Alt-C), `nvm` if installed, `EDITOR=nvim`. Machine-specific settings go in `~/.zshrc.local`, which is sourced last and never tracked.
- **git** (`.gitconfig`): sensible defaults (`pull.ff = only`, `push.autoSetupRemote`, `fetch.prune`, `rebase.autoStash`) and a few aliases (`st`, `lg`, `last`, `amend`, ...).
- **iTerm2** (`iterm2/`): the profile and a curated set of global preferences, including `Cmd-]` / `Cmd-[` as next/previous pane, which iTerm2 otherwise doesn't honour while Neovim has focus.

## Git identity

Identity isn't in `.gitconfig`; it's layered, and later entries win:

1. `~/.gitconfig.local` — the machine's default identity (untracked). `install.sh` creates it from your previous `~/.gitconfig`, or from `.gitconfig-personal` on a fresh machine.
2. `~/.gitconfig-personal` — applied automatically to every repo under **`~/workspace/psnl/`** via `includeIf "gitdir:~/workspace/psnl/"`.

So on a machine that also has work repos, work stays the default and anything under `~/workspace/psnl/` commits as the personal account. Check with `git config user.email` inside a repo.

The personal identity uses GitHub's private `…@users.noreply.github.com` address, so no real email is committed to the public history.

## iTerm2 notes

- `iterm2/Sid.json` is installed as a [Dynamic Profile](https://iterm2.com/documentation-dynamic-profiles.html): iTerm2 loads it automatically and edits to the file show up live. Dynamic profiles are read-only in the GUI, so change the JSON, not the settings window.
- `iterm2/global-prefs.plist` only holds the preferences worth syncing (it deliberately leaves out window positions, IDs, and AI settings). `apply-prefs.sh` merges those keys into iTerm2's preferences and leaves everything else alone. iTerm2 rewrites its preferences on quit, so quit it before running the script.

## Notes

- The tmux clipboard binding uses `pbcopy`, so it's macOS-only.
- Neovim won't load `init.vim` and `init.lua` together; `install.sh` moves an old `init.vim` aside.
- If `~/.zshrc` already existed, it's saved as `~/.zshrc.bak.<timestamp>`; move anything machine-specific into `~/.zshrc.local`.
