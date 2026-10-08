# plog — stream a tmux pane's output into a log file that Claude sessions (or
# anything else) can `tail` / `grep`, while the pane keeps showing it as usual.
#
#   plog start [--raw] [<pane>] <name>   log <pane> to ~/.tmux-logs/<name>.log
#   plog stop  [<pane>]                  stop logging that pane (file is kept)
#   plog ls                              panes currently being logged + log sizes
#   plog tail  <name> [tail args]        tail -f the log (default: last 50 lines)
#
# <pane> is a tmux target: session:window.pane (e.g. work:3.1), or any pane id
# from `tmux list-panes -a`. It may live in a different tmux session than the
# caller. If omitted and plog runs inside tmux, it means the current pane.
#
# `start` is idempotent (a second start replaces the pipe, it never toggles it
# off) and appends, so restarting keeps earlier output. By default ANSI colours,
# title escapes and \r are stripped so the log is readable; --raw keeps them.
# Underneath this is `tmux pipe-pane`; see tmux-cheatsheet.md for the concepts.

_PLOG_DIR="${PLOG_DIR:-$HOME/.tmux-logs}"

# perl filter: strip CSI sequences, OSC/title (ESC ] ... and ESC k ...) sequences,
# stray keypad-mode escapes (ESC = / ESC >) and \r. $|=1 disables output
# buffering, otherwise `tail -f` on the log lags. (macOS sed can't match \e.)
_PLOG_STRIP='BEGIN{$|=1} s/\e\[[0-9;?]*[ -\/]*[@-~]//g; s/\e\][^\a\e]*(\a|\e\\)//g; s/\ek[^\e]*\e\\//g; s/\e[=>]//g; s/\r//g'

plog() {
  command -v tmux >/dev/null 2>&1 || { echo "plog: tmux not found" >&2; return 1; }
  local sub="${1:-}"
  [[ $# -gt 0 ]] && shift

  case "$sub" in
    start)
      local raw=0
      if [[ "${1:-}" == "--raw" ]]; then raw=1; shift; fi
      local target name
      if [[ $# -eq 2 ]]; then
        target="$1" name="$2"
      elif [[ $# -eq 1 && -n "${TMUX_PANE:-}" ]]; then
        target="$TMUX_PANE" name="$1"
      else
        echo "usage: plog start [--raw] [<pane>] <name>   (pane optional only inside tmux)" >&2
        return 2
      fi
      name="${name%.log}"
      if [[ ! "$name" =~ '^[A-Za-z0-9._-]+$' ]]; then
        echo "plog: name must be letters, digits, '.', '_' or '-' (got: $name)" >&2
        return 2
      fi
      tmux display-message -p -t "$target" '#{pane_id}' >/dev/null 2>&1 || {
        echo "plog: no such pane: $target  (see: tmux list-panes -a)" >&2
        return 1
      }
      mkdir -p "$_PLOG_DIR"
      local file="$_PLOG_DIR/$name.log" cmd
      if (( raw )); then
        cmd="cat >> '$file'"
      else
        cmd="perl -pe '$_PLOG_STRIP' >> '$file'"
      fi
      # No -o: it is a toggle. Without it a new pipe replaces any existing one.
      tmux pipe-pane -t "$target" "$cmd" || return 1
      echo "logging $target -> $file"
      ;;

    stop)
      local target="${1:-${TMUX_PANE:-}}"
      if [[ -z "$target" ]]; then
        echo "usage: plog stop [<pane>]   (pane optional only inside tmux)" >&2
        return 2
      fi
      tmux display-message -p -t "$target" '#{pane_id}' >/dev/null 2>&1 || {
        echo "plog: no such pane: $target" >&2
        return 1
      }
      tmux pipe-pane -t "$target" && echo "stopped logging $target"
      ;;

    ls)
      echo "Panes being logged:"
      local out
      out=$(tmux list-panes -a -F '#{pane_pipe} #{session_name}:#{window_index}.#{pane_index} (#{pane_current_command})' 2>/dev/null \
            | sed -n 's/^1 /  /p')
      echo "${out:-  (none)}"
      echo "Logs in $_PLOG_DIR:"
      local logs
      logs=$(find "$_PLOG_DIR" -maxdepth 1 -name '*.log' 2>/dev/null)
      if [[ -n "$logs" ]]; then
        echo "$logs" | sort | while IFS= read -r f; do
          printf '  %s\t%s\n' "$(du -h "$f" | cut -f1)" "$f"
        done
      else
        echo "  (none)"
      fi
      ;;

    tail)
      local name="${1:-}"
      if [[ -z "$name" ]]; then echo "usage: plog tail <name> [tail args]" >&2; return 2; fi
      shift
      name="${name%.log}"
      local file="$_PLOG_DIR/$name.log"
      [[ -f "$file" ]] || { echo "plog: no such log: $file" >&2; return 1; }
      if [[ $# -eq 0 ]]; then set -- -n 50; fi
      tail -f "$@" "$file"
      ;;

    ""|-h|--help|help)
      cat <<'USAGE'
plog start [--raw] [<pane>] <name>   log <pane> to ~/.tmux-logs/<name>.log
plog stop  [<pane>]                  stop logging that pane (file is kept)
plog ls                              panes currently being logged + log sizes
plog tail  <name> [tail args]        tail -f the log (default: last 50 lines)
<pane> = tmux target, e.g. work:3.1; optional when run inside the pane itself.
USAGE
      ;;

    *)
      echo "plog: unknown command '$sub' (start|stop|ls|tail)" >&2
      return 2
      ;;
  esac
}
