source $BYOBU_PREFIX/share/byobu/profiles/tmux


## Set default editor.
set -g editor hx

## Enable mouse support.
set -g mouse on

## Count windows and panes from 1, not 0.
set -g base-index 1
set -g pane-base-index 1

## Renumber windows on adds/deletes/etc.
set -g renumber-windows on

## Set pane border visuals.
set -g pane-border-lines heavy

## Don't detach when closing a session,
## and don't close sessions when we detach.
set -g detach-on-destroy off
set -g destroy-unattached off

## Fix an issue with status bar left spacing,
## and date/time always showing on the right.
set -g status-left ' #[fg=white,bold]#( hostname | tr a-z A-Z )#[default] #(byobu-status tmux_left) '
set -g status-right '#(byobu-status tmux_right) '

## As of tmux 3.3a, copy-paste and OSC-52 support are a bit wonky.
## We'll work around this by controlling the implementation ourselves.
## (See https://github.com/tmux/tmux/issues/3646 for more info on this.)
set -g allow-passthrough on
set -g copy-command '/home/nestor/bin/vendor/osc52 -f'

## ----------------------------------------------------------------------------
## ----------------------------------------------------------------------------


## Handy shortcuts.


## These are the regex matchers that correct for bad names.
COMMAND='#{?#{==:#{pane_current_command},#{b:SHELL}},>_,#{pane_current_command}}'
##
CLEAN_TO_DASH="s/^(-| +|title)?\$/-/"
CLEAN_TO_COMMAND="s/^(-| +|title)?\$/$COMMAND/"


## - "fixed" window name: #{?window_name,#{$CLEAN_TO_DASH:window_name},-}
## - "fixed" pane name: #{?pane_title,#{$CLEAN_TO_COMMAND:pane_title},$COMMAND}


## ----------------------------------------------------------------------------


## Update the terminal emulator title as needed.
set -g set-titles on
set -g set-titles-string "#( hostname )"


## ----------------------------------------------------------------------------
## Set up window titles.


## Human-readable window title string:
##
##   [
##     #{?window_name,
##       #{$CLEAN_TO_DASH:window_name}
##       ,
##       -
##     }
##     #{?window_zoomed_flag, 🔍,}
##     #{?window_marked_flag, 🎯,}
##   ]
##
WINDOW_FORMAT=" #{?window_name,#{$CLEAN_TO_DASH:window_name},-}#{?window_zoomed_flag, 🔍,}#{?window_marked_flag, 🎯,} "

set -g window-status-format "$WINDOW_FORMAT"
set -g window-status-current-format "#[fg=white,bold,bg=brightblack]${WINDOW_FORMAT}#[default]"


## ----------------------------------------------------------------------------
## Set up pane titles.


## Human-readable pane title string:
##
##   #{?pane_marked,🎯 ,}
##   #{?pane_title,
##     #{$CLEAN_TO_COMMAND:pane_title}
##     ,
##     $COMMAND
##   }
##
PANE_FORMAT="#{?pane_marked,🎯 ,}#{?pane_title,#{$CLEAN_TO_COMMAND:pane_title},$COMMAND}"

set -g pane-border-status top
set -g pane-border-format "#[fg=white,bold] $PANE_FORMAT #[default]"
