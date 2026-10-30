# dotfiles

My editor, terminal, and shell setup: Neovim/Vim, tmux, zsh (Oh My Zsh), git, and iTerm2. macOS-oriented.

## Install

```bash
git clone git@github.com:sidb101/dotfiles.git ~/dotfiles
cd ~/dotfiles
brew bundle                              # install the tools below (incl. iTerm2)
./install.sh                             # everything else
```

**Quit iTerm2 and run `install.sh` from Terminal.app.** iTerm2 rewrites its preferences when it quits, which would undo what the script applies, so `install.sh` stops before changing anything while iTerm2 is running.

`install.sh`:

1. symlinks the files below into `$HOME` (existing real files are backed up as `<file>.bak.<timestamp>`);
2. creates an empty `~/.zshrc.local` if there isn't one (it's never overwritten);
3. installs Oh My Zsh if it's missing (`extras/install-ohmyzsh.sh`);
4. if iTerm2 is installed, links the profile, applies the global prefs and makes `Sid` the default profile (`extras/install-iterm2.sh`).

Re-running is safe, and is also how you update a machine after a `git pull`.

## Layout

```
dotfiles/
  install.sh              # the whole install/update: symlinks, ~/.zshrc.local, Oh My Zsh, iTerm2
  Brewfile                # git, gh, neovim, tmux, fzf, ripgrep, jq, iTerm2
  .vimrc                  # shared Vim + Neovim settings (Neovim sources it)
  nvim/init.lua           # Neovim entrypoint: sources ~/.vimrc, adds Tokyo Night (follows macOS light/dark)
  .tmux.conf              # tmux config
  tmux-cheatsheet.md      # tmux keys and workflow
  .zshrc                  # Oh My Zsh (afowler), history, fzf, nvm, EDITOR=nvim
  .zshrc.local.example    # example of what goes in ~/.zshrc.local (install.sh creates that file, empty)
  shell/tmuxlog.zsh       # plog: log a tmux pane to a file (sourced by .zshrc)
  .gitconfig              # shared git defaults and aliases (no identity)
  .gitconfig-personal     # personal identity (GitHub noreply address)
  .gitignore_global       # .DS_Store, swap files, ...
  iterm2/
    Sid.json              # iTerm2 profile (loaded as a Dynamic Profile)
    global-prefs.plist    # curated global prefs: key bindings, tab bar, ...
    apply-prefs.sh        # merges global-prefs.plist into iTerm2's preferences
  extras/
    install-ohmyzsh.sh    # installs Oh My Zsh without touching ~/.zshrc (run by install.sh)
    install-iterm2.sh     # installs iTerm2, links the profile, applies prefs (run by install.sh)
```

## What you get

- **Vim / Neovim** (`.vimrc`): absolute + relative line numbers, 80-column guide, `autoread` (picks up edits made by other programs), and a tidier `netrw` file explorer (30-column sidebar, tree view, opens files in the previous window).
- **Neovim only** (`nvim/init.lua`): installs [Tokyo Night](https://github.com/folke/tokyonight.nvim) with Neovim's built-in `vim.pack`, so there's no plugin-manager bootstrap. On macOS it follows the system appearance (`night` in dark mode, `day` in light mode) and re-checks whenever Neovim regains focus. Falls back to the `.vimrc` colorscheme if the plugin isn't available. Needs Neovim 0.12+.
- **tmux** (`.tmux.conf`): mouse support, windows numbered from 1, splits and new windows open in the current directory, true color, drag-to-copy to the macOS clipboard (`pbcopy`), `Shift-Enter` passthrough (`extended-keys`), a higher-contrast status bar, and 50k lines of scrollback per pane. Needs tmux 3.2+. Keys are in [`tmux-cheatsheet.md`](tmux-cheatsheet.md).
- **zsh** (`.zshrc`): Oh My Zsh with the `afowler` theme, 100k-line history, `fzf` key bindings (Ctrl-R, Ctrl-T, Alt-C), `nvm` if installed, `EDITOR=nvim`. Machine-specific settings go in `~/.zshrc.local`, which `install.sh` creates empty, `.zshrc` sources last, and git never tracks; [`.zshrc.local.example`](.zshrc.local.example) shows the kind of thing that belongs there (tool PATHs, `JAVA_HOME`, rbenv) and can be copied from.
- **plog** (`shell/tmuxlog.zsh`, sourced by `.zshrc`): log a tmux pane to `~/.tmux-logs/<name>.log` while it keeps showing as usual, so another terminal (or a Claude session) can `tail` / `grep` it. Wraps `tmux pipe-pane` with explicit start/stop and ANSI stripping:

  ```bash
  plog start work:3.1 dev-server   # pane = session:window.pane; omit it when run inside the pane
  plog ls                          # panes being logged + log sizes
  plog tail dev-server             # tail -f the log
  plog stop work:3.1               # stop (the file is kept)
  ```

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
- Colours follow the system appearance: Tokyo Night Day in light mode and Tokyo Night Night in dark mode (the same pair Neovim uses), taken from tokyonight.nvim's `extras/iterm/*.itermcolors`. The 16 ANSI colours differ per mode, so prompt colours such as the git branch stay readable on both backgrounds. The profile also sets minimum contrast to about 50% and faint text to fully opaque, which keeps dim text legible on the light background (tuned by eye; adjust in Settings → Colors, then mirror the change into `iterm2/Sid.json`).
- `iterm2/global-prefs.plist` only holds the preferences worth syncing (it deliberately leaves out window positions, install IDs, update timestamps, and AI settings). The one ID it does hold is `Default Bookmark Guid`, which makes `Sid` the default profile. It also holds `ApplePressAndHoldEnabled = false`, a macOS key stored in iTerm2's own domain: holding a key repeats it in iTerm2 (for `hjkl` in Vim) instead of showing the accent popup, and other apps are unaffected. `apply-prefs.sh` merges those keys into iTerm2's preferences and leaves everything else alone. iTerm2 rewrites its preferences on quit, so quit it before running the script (`install.sh` checks).
- Don't turn on write-back for the dynamic profile: iTerm2 rewrites `Sid.json` through the symlink and can strip it down to a few keys. Change the JSON in the repo instead.

## Notes

- The tmux clipboard binding uses `pbcopy`, so it's macOS-only.
- Neovim won't load `init.vim` and `init.lua` together; `install.sh` moves an old `init.vim` aside.
- If `~/.zshrc` already existed, it's saved as `~/.zshrc.bak.<timestamp>`; move anything machine-specific into `~/.zshrc.local`.
