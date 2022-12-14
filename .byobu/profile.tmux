source $BYOBU_PREFIX/share/byobu/profiles/tmux


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
set -g status-left '#[fg=white,bold,bg=red]  #( hostname | tr a-z A-Z ) #[default] #(byobu-status tmux_left)'
set -g status-right '#(byobu-status tmux_right)'


## ----------------------------------------------------------------------------
## ----------------------------------------------------------------------------


## Handy shortcuts.


## These are the regex matchers that correct for bad names.
CLEAN_TO_DASH='s/^(-| +|title)?$/-/'
CLEAN_TO_PROCESS='s/^(-| +|title)?$/#{pane_current_command}/'


## - "fixed" window name: #{?window_name,#{$CLEAN_TO_DASH:window_name},-}
## - "fixed" pane name: #{?pane_title,#{$CLEAN_TO_PROCESS:pane_title},#{pane_current_command}}


## ----------------------------------------------------------------------------


## Update the terminal emulator title as needed.
set -g set-titles on
set -g set-titles-string "#( hostname )"


## ----------------------------------------------------------------------------
## Set up window titles.


## Human-readable window title string:
##
##   #{window_index}
##   :
##   #{?window_name,
##     #{$CLEAN_TO_DASH:window_name}
##     ,
##     -
##   }
##   #{?window_zoomed_flag,🔍 ,}
##   #{?window_marked_flag,💢 ,}
##
WINDOW_FORMAT="#{window_index}: #{?window_name,#{$CLEAN_TO_DASH:window_name},-} #{?window_zoomed_flag,🔍 ,}#{?window_marked_flag,💢 ,}"

set -g window-status-format "$WINDOW_FORMAT"
set -g window-status-current-format "#[fg=white,bold,bg=red] ${WINDOW_FORMAT}#[default]"


## ----------------------------------------------------------------------------
## Set up pane titles.


## Human-readable pane title string:
##
##   #{?pane_marked,💢 ,}
##   #{?pane_title,
##     #{$CLEAN_TO_PROCESS:pane_title}
##     ,
##     #{pane_current_command
##   }
##
PANE_FORMAT="#{?pane_marked,💢 ,}#{?pane_title,#{$CLEAN_TO_PROCESS:pane_title},#{pane_current_command}}"

set -g pane-border-status top
set -g pane-border-format "#[fg=white,bold] $PANE_FORMAT #[default]"
