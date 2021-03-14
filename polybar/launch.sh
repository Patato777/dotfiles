#!/usr/bin/env bash

# Terminate already running bar instances
killall -9 polybar
# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit

# Launch mybar
echo "---" | tee -a /tmp/mypolybar.log
polybar mybar >>/tmp/mypolybar.log 2>&1 & disown
polybar bottombar >>/tmp/mypolybar.log 2>&1 & disown
echo "Bars launched..."
