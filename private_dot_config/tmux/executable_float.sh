#!/usr/bin/env bash
# Simple floating pane manager for tmux.
# Usage: float.sh [toggle|resize-in|resize-out] [window_id]
#
# Uses a persistent per-window "scratch" session shown in a tmux popup.
# Each tmux window (tab) gets its own float session named float-@<id>.
# Resize reopens the popup with new dimensions, and restores
# the key table to "normal" mode so +/- can be pressed repeatedly.

set -e

WINDOW_ID="${2:-$(tmux display-message -p '#{window_id}')}"
SESSION="float-${WINDOW_ID}"
ACTION="${1:-toggle}"
WIDTH_VAR="FLOAT_WIDTH_${WINDOW_ID}"
HEIGHT_VAR="FLOAT_HEIGHT_${WINDOW_ID}"
DEFAULT_WIDTH="80%"
DEFAULT_HEIGHT="80%"

get_dim() {
    val=$(tmux showenv -g "$1" 2>/dev/null | cut -d= -f2-)
    [ -z "$val" ] && val="$2"
    echo "$val"
}

current_session=$(tmux display-message -p '#{session_name}')

case "$ACTION" in
    toggle)
        if [[ "$current_session" == float-* ]]; then
            # Inside float — close it
            tmux detach-client
        else
            # Outside float — open it
            tmux setenv -g FLOAT_ORIGIN "$current_session"

            if ! tmux has-session -t "$SESSION" 2>/dev/null; then
                cwd=$(tmux display-message -p '#{pane_current_path}')
                tmux new-session -d -s "$SESSION" -c "$cwd"
                tmux set-option -t "$SESSION" status off
            else
                # Sync cwd
                cwd=$(tmux display-message -p '#{pane_current_path}')
                float_cwd=$(tmux display -t "$SESSION" -p '#{pane_current_path}')
                if [ "$cwd" != "$float_cwd" ]; then
                    tmux send-keys -t "$SESSION" " cd \"$cwd\"" C-m
                fi
            fi

            w=$(get_dim "$WIDTH_VAR" "$DEFAULT_WIDTH")
            h=$(get_dim "$HEIGHT_VAR" "$DEFAULT_HEIGHT")

            tmux popup \
                -S "fg=magenta" \
                -w "$w" -h "$h" \
                -b rounded \
                -E "tmux attach-session -t $SESSION"
        fi
        ;;

    resize-in|resize-out)
        if [[ "$current_session" != float-* ]]; then
            exit 0
        fi

        # When resizing, the session IS the float session, so derive window ID from it
        SESSION="$current_session"
        WINDOW_ID="${SESSION#float-}"
        WIDTH_VAR="FLOAT_WIDTH_${WINDOW_ID}"
        HEIGHT_VAR="FLOAT_HEIGHT_${WINDOW_ID}"

        w=$(get_dim "$WIDTH_VAR" "$DEFAULT_WIDTH")
        h=$(get_dim "$HEIGHT_VAR" "$DEFAULT_HEIGHT")

        # Convert % to absolute if needed
        term_w=$(tmux display -p -t "$(tmux showenv -g FLOAT_ORIGIN 2>/dev/null | cut -d= -f2-)" '#{window_width}' 2>/dev/null || echo 200)
        term_h=$(tmux display -p -t "$(tmux showenv -g FLOAT_ORIGIN 2>/dev/null | cut -d= -f2-)" '#{window_height}' 2>/dev/null || echo 50)

        # Get current popup dimensions from the window size inside the popup
        cur_w=$(tmux display -p '#{window_width}')
        cur_h=$(tmux display -p '#{window_height}')

        step=5
        if [ "$ACTION" = "resize-in" ]; then
            step=-5
        fi

        new_w=$((cur_w + step))
        new_h=$((cur_h + step))

        # Bounds check
        [ "$new_w" -le 10 ] && exit 0
        [ "$new_h" -le 5 ] && exit 0
        [ "$new_w" -gt "$term_w" ] && exit 0
        [ "$new_h" -gt "$term_h" ] && exit 0

        tmux setenv -g "$WIDTH_VAR" "$new_w"
        tmux setenv -g "$HEIGHT_VAR" "$new_h"

        # Set flag so hook restores normal mode after popup reopens
        tmux setenv -g FLOAT_RESTORE_NORMAL 1

        # Detach and reopen with new size
        tmux detach-client
        tmux popup \
            -S "fg=magenta" \
            -w "$new_w" -h "$new_h" \
            -b rounded \
            -E "tmux attach-session -t $SESSION"
        ;;

    nav-left|nav-right)
        if [[ "$current_session" != float-* ]]; then
            exit 0
        fi

        origin=$(tmux showenv -g FLOAT_ORIGIN 2>/dev/null | cut -d= -f2-)
        [ -z "$origin" ] && exit 0

        if [ "$ACTION" = "nav-left" ]; then
            tmux previous-window -t "$origin"
        else
            tmux next-window -t "$origin"
        fi
        tmux detach-client
        ;;
esac
