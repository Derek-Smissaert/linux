#!/bin/bash

# Get pane count
pane_count=$(tmux list-panes | wc -l)

# If only one pane, split it and run bash
if [ "$pane_count" -eq 1 ]; then
  tmux split-window -v -p 25 "bash"
  tmux select-pane -t 1       # focus on opened bash pane
else
  # Check if main pane is zoomed
  if tmux display-message -p '#{window_zoomed_flag}' | grep -q 1; then
    tmux resize-pane -Z       # unzoom to show bash
    tmux select-pane -t 1     # focus on opened bash pane
  else
    tmux select-pane -t 0     # ensure focus returns to main
    tmux resize-pane -Z       # zoom again
  fi
fi
