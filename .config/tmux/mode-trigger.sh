#!/bin/bash

if [ "$1" == "copy-mode" ] || [ "$1" == "view-mode" ]; then
  # Set the background color to your preferred color when copy mode is entered
  tmux setw -g status-bg 'colour203'
else
  # Reset the background color to the original color when copy mode is exited
  tmux setw -g status-bg 'colour188'
fi
