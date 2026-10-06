# tmux cheatsheet

Every command starts with the **prefix**, `Ctrl-b`. Press it, release it, then press the next key. `prefix c` means `Ctrl-b` then `c`.

| Term | Cursor equivalent |
|---|---|
| session | the whole terminal panel |
| window | one named terminal in the list |
| pane | a split inside one terminal |

## Sessions

| Command | Action |
|---|---|
| `tmux new -s work` | start a session named "work" |
| `tmux ls` | list sessions |
| `tmux attach -t work` (or `tmux a`) | reattach |
| `prefix d` | detach (everything keeps running) |
| `tmux kill-server` | end all sessions |

## Windows (named terminals)

| Keys | Action |
|---|---|
| `prefix c` | new window |
| `prefix ,` | rename window |
| `prefix n` / `prefix p` | next / previous window |
| `prefix 1`…`9` | jump to window by number (numbering starts at 1) |
| `prefix w` | pick from a list of windows |
| `prefix &` | kill window (or type `exit`) |

## Panes (splits)

| Keys | Action |
|---|---|
| `prefix %` | split left / right |
| `prefix "` | split top / bottom |
| `prefix` + arrow | move between panes |
| `prefix z` | zoom pane to full screen (again to unzoom) |
| `prefix x` | close pane |

## Scrolling and copying

- `prefix [` enters scroll mode. Move with arrows or `j`/`k`, search with `/`, quit with `q`.
- Mouse is on, so trackpad scrolling and clicking panes also work.

## Config

- File: `~/.tmux.conf`
- Reload: `tmux source ~/.tmux.conf`

## Traps

- Release `Ctrl-b` before pressing the next key.
- Don't type `tmux` inside tmux (nests sessions). Use `prefix c` for a new window.
- Closing the iTerm tab doesn't kill tmux. Use `tmux a` to get it back.
