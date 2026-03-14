#!/usr/bin/env bash
# Move focus to pane in direction, or switch window/tab if at the edge.
# Usage: move-focus-or-tab.sh left|right

direction="$1"
pane_count="$(tmux list-panes | wc -l | tr -d ' ')"

# Single pane — just switch window
if [ "$pane_count" -eq 1 ]; then
  case "$direction" in
    left)  tmux previous-window ;;
    right) tmux next-window ;;
  esac
  exit 0
fi

# Multiple panes — check if at the edge using pane position
current_pane_id="$(tmux display-message -p '#{pane_id}')"

if [ "$direction" = "left" ]; then
  # Get the leftmost pane (smallest pane_left)
  at_edge="$(tmux display-message -p '#{pane_at_left}')"
  if [ "$at_edge" = "1" ]; then
    tmux previous-window
  else
    tmux select-pane -L
  fi
elif [ "$direction" = "right" ]; then
  at_edge="$(tmux display-message -p '#{pane_at_right}')"
  if [ "$at_edge" = "1" ]; then
    tmux next-window
  else
    tmux select-pane -R
  fi
fi
