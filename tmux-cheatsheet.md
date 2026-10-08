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

## Piping pane output somewhere else (for sharing with Claude sessions)

Two different tools. Pick by whether you want history or a live feed.

| Tool | What it gives | Use when |
|---|---|---|
| `capture-pane -p` | one **snapshot** of what is on screen / in scrollback, printed to stdout | "look at that pane right now" |
| `pipe-pane` | a **live stream** of everything the pane prints from now on, sent to a command | a durable log other sessions can `tail` / `grep` |

### Snapshot: `capture-pane`

```
tmux capture-pane -p -t work:3.1                # visible screen only
tmux capture-pane -p -J -S -2000 -t work:3.1    # last 2000 lines, wrapped lines re-joined
tmux capture-pane -p -J -S - -t work:3.1        # the entire scrollback
tmux capture-pane -p -t work:3.1 > /tmp/pane.txt
```

- `-p` print to stdout (without it, it goes to a tmux paste buffer).
- `-S -N` start N lines up in scrollback (`-S -` = from the very beginning). `-J` joins wrapped lines.
- No colour codes by default (`-e` adds them). Nothing to clean up, and it needs no setup beforehand: great for "what did that crash say?"
- Limit: only what is still in scrollback (`history-limit` in `~/.tmux.conf`).

### Live stream: `pipe-pane`

```
tmux pipe-pane -o -t work:3.1 'cat >> ~/.tmux-logs/btnextjs.log'   # start (or toggle, see -o)
tmux pipe-pane -t work:3.1                                           # no command = STOP
tmux display -p -t work:3.1 '#{pane_pipe}'                           # 1 = piping, 0 = not
```

- Target is `session:window.pane` (`work:3.1` = session work, window 3, pane 1). List them with `tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_current_command}'`.
- The command runs under `sh -c`, receives the pane's output on **stdin**, and its stdout/stderr go nowhere visible. Always redirect into a file (`>>`), or into another command that does.
- `-o` makes it a **toggle**: if the pane has no pipe it starts one, if it already has one it stops it. Run the same `-o` line twice and you are back to off. Without `-o`, a new command *replaces* the old one (safe to re-run to restart). Check `#{pane_pipe}` if unsure.
- One pipe per pane. Stopping the pipe does not stop the program in the pane, and does not delete the file.
- It only captures output from the moment you start it. Anything printed earlier: use `capture-pane -S -`.
- Output direction: `-O` (default) is pane → command. `-I` is the reverse (command's stdout is typed into the pane as input). Rarely needed.

### Clean version (strip colours, title escapes, `\r`)

Raw pane output is full of ANSI escapes and carriage returns. For logs Claude will read, strip them. macOS `sed` can't do `\e`, so use perl (`$|=1` stops it buffering, otherwise `tail -f` lags):

```
tmux pipe-pane -o -t work:3.1 "perl -pe 'BEGIN{\$|=1} s/\e\[[0-9;?]*[ -\/]*[@-~]//g; s/\e\][^\a\e]*(\a|\e\\\\)//g; s/\r//g' >> ~/.tmux-logs/btnextjs.log"
```

Tested: coloured `red line` arrives as plain `red line`. Typing at a shell prompt still leaves some line-editor noise (zsh redraws); a long-running process's output (dev server, tests, tailing logs) comes through clean. So pipe the pane running the *server*, not your interactive shell.

### One shared place for many readers

Convention: one directory, one file per pane, descriptive names.

```
mkdir -p ~/.tmux-logs
# writer: the dev-server pane
tmux pipe-pane -o -t work:3.1 "perl -pe '…' >> ~/.tmux-logs/btnextjs.log"
# readers: any number of Claude sessions / terminals, concurrently, read-only
tail -n 200 ~/.tmux-logs/btnextjs.log
tail -f ~/.tmux-logs/btnextjs.log | grep -i error
grep -n 'Program widget result' ~/.tmux-logs/btnextjs.log | tail
```

Appending writer + many readers is safe on one machine (readers never lock or alter the file). Tell a Claude session the **path**, and that it is a live log (`tail`, don't `cat` a multi-MB file whole).

Housekeeping, since the file grows forever:

- Truncate while piping: `: > ~/.tmux-logs/btnextjs.log` (the writer keeps appending, thanks to `>>`).
- Or rotate by stopping and restarting: `mv` the file, then `pipe-pane -o` again.
- Check size: `ls -lh ~/.tmux-logs`. A busy dev server was ~15 MB per day.
- Logs hold whatever the app prints: tokens, key prefixes, customer data. Keep them under `~/` (not a shared or synced folder) and delete when done.
- A pipe dies with its pane/session; it does **not** survive a tmux server restart. Re-run the command.

### Other ways to feed the same file

| Need | Command |
|---|---|
| Just save + still see output, for one command | `yarn dev 2>&1 \| tee ~/.tmux-logs/dev.log` (loses colours/TTY behaviour in some tools) |
| Whole terminal session recorded | `script -q ~/.tmux-logs/session.log` (type `exit` to end) |
| Send a command into another pane | `tmux send-keys -t work:3.1 'yarn test' Enter` |
| Block until something happens | `tmux wait-for name` / `tmux wait-for -S name` |

### Handy: toggle logging with a key

Add to `~/.tmux.conf` (then `tmux source ~/.tmux.conf`). `prefix P` starts logging the current pane into a file named after its window, pressing it again stops it:

```
bind P pipe-pane -o "cat >> ~/.tmux-logs/#{session_name}-#{window_name}.log" \; display-message "pipe-pane toggled"
```

(`#{…}` formats expand inside pipe-pane commands. Make sure `~/.tmux-logs` exists first.)

### Traps

- `pipe-pane` with no command stops the pipe. It does not error if none is running.
- Forgetting `>>` (using `>`) truncates the file every time a pipe starts.
- Quoting: tmux wraps the command in `sh -c`; inside double quotes escape `$` as `\$`, as above.
- A pipe left running silently keeps writing to disk. `#{pane_pipe}` tells you whether one is on; add it to the status line if you tend to forget: `set -g status-right '#{?pane_pipe,● LOGGING ,}%H:%M'`.
