## Clear All Keybindings
source $BYOBU_PREFIX/share/byobu/keybindings/f-keys.tmux.disable




## Set Custom Escape Sequences

	## To define a new key sequence:
	##   cat -vA  # (used to determine what the system sees in response to your keypress)
	##   set -s user-keys[0] "[the key press as revealed via `cat`]"
	##   set -s user-keys[1] "[the key press as revealed via `cat`]"

	## To *bind* a user-defined key sequence:
	##   bind-key -n User0 ...
	##   bind-key -n User1 ...




## Non-Session/Window/Pane Commands

	## Allow arbitrary shell command execution.
	bind-key -n M-Space        command-prompt -p "#[bold] (blind command)" "run-shell \"blindly %%\""
  bind-key -n M-C-Space      command-prompt -p "#[bold] (toast command)" "run-shell \"%% | toast --hold\""

	## Allow in-context tmux command execution.
	bind-key -n M-x            command-prompt -p "#[bold] (tmux command)" "%%"

	## Pop up a "scratch pad" window.
	bind-key -n M-m            display-popup -E -w 75% -h 75%

	## Reload Profile.
	bind-key -n M-`            source $BYOBU_PREFIX/share/byobu/profiles/tmuxrc




## Session Management

  bind-key -n M-C-n          new-session
  bind-key -n M-C-s          command-prompt -p "#[bold] (rename-session)" "rename-session '%%'"

  bind-key -n M-,            switch-client -p
  bind-key -n M-.            switch-client -n

  bind-key -n M-C-d          confirm-before -p "#[bold] Detach From Session?" detach
  bind-key -n M-C-q          confirm-before -p "#[bold] Close All Windows In Session?" kill-session




## Window Management

  bind-key -n M-n            new-window -c "#{pane_current_path}" \; rename-window "" \; select-pane -T ""

  bind-key -n M-u            previous-window
  bind-key -n M-o            next-window

  bind-key -n M-C-u          swap-window -t -1 \; select-window -t -1
  bind-key -n M-C-o          swap-window -t +1 \; select-window -t +1

  bind-key -n M-C-r          command-prompt -p "#[bold] (rename-window)" "rename-window '%%'"
  bind-key -n M-BSpace       confirm-before -p "#[bold] Close Window (And All Panes)?" kill-window




## Pane Management/Navigation

  bind-key -n M-]            split-window -h -c "#{pane_current_path}" \; select-pane -T ""
  bind-key -n M-[            split-window -v -c "#{pane_current_path}" \; select-pane -T ""
  bind-key -n M-p            confirm-before -p "#[bold] Pop Out This Pane (Into Its Own Window)?" break-pane

  bind-key -n M--            select-pane -m
  bind-key -n M-=            swap-pane \; select-pane -M

  bind-key -n M-i            select-pane -U
  bind-key -n M-k            select-pane -D
  bind-key -n M-j            select-pane -L
  bind-key -n M-l            select-pane -R

  bind-key -n M-C-i          resize-pane -U
  bind-key -n M-C-k          resize-pane -D
  bind-key -n M-C-j          resize-pane -L
  bind-key -n M-C-l          resize-pane -R

  bind-key -n M-/            choose-tree -Z
  bind-key -n M-z            resize-pane -Z
  bind-key -n M-a            set -w synchronize-panes \; run-shell "toast \"All-Pane Input: $( tmux show -w synchronize-panes | ends-with? ' on' && echo 'On' || echo 'Off' )\""

  bind-key -n M-r            command-prompt -p "#[bold] (rename-pane)" "select-pane -T '%%'"
  bind-key -n M-\'           kill-pane


  ## "Copy Mode" (Scroll-Back Buffer) Control

    bind-key -n M-s          copy-mode
    bind-key -n M-c          capture-pane -S -32768 \; save-buffer "$BYOBU_RUN_DIR/printscreen" \; delete-buffer \; new-window -n "PRINTSCREEN" "COLORTERM='truecolor' $BYOBU_EDITOR $BYOBU_RUN_DIR/printscreen"


  ## "Copy Mode" (Scroll-Back Buffer) Navigation

  	## Allow arbitrary shell command execution.
  	bind-key -T copy-mode-vi M-Space        command-prompt -p "#[bold] (blind command)" "run-shell \"blindly %%\""
    bind-key -T copy-mode-vi M-C-Space      command-prompt -p "#[bold] (toast command)" "run-shell \"%% | toast --hold\""

  	## Allow in-context tmux command execution.
  	bind-key -T copy-mode-vi M-x            command-prompt -p "#[bold] (tmux command)" "%%"

    bind-key -T copy-mode-vi q              send-keys -X cancel
    bind-key -T copy-mode-vi Escape         send-keys -X cancel
    bind-key -T copy-mode-vi S              capture-pane -S -32768 \; save-buffer "$BYOBU_RUN_DIR/printscreen" \; delete-buffer \; send-keys -X cancel \; new-window -n "PRINTSCREEN" "COLORTERM='truecolor' $BYOBU_EDITOR $BYOBU_RUN_DIR/printscreen"

    bind-key -T copy-mode-vi i              send-keys -X cursor-up
    bind-key -T copy-mode-vi k              send-keys -X cursor-down
    bind-key -T copy-mode-vi j              send-keys -X cursor-left
    bind-key -T copy-mode-vi l              send-keys -X cursor-right

    bind-key -T copy-mode-vi I              send-keys -X halfpage-up
    bind-key -T copy-mode-vi K              send-keys -X halfpage-down
    bind-key -T copy-mode-vi J              send-keys -X previous-word
    bind-key -T copy-mode-vi L              send-keys -X next-word-end

    bind-key -T copy-mode-vi C-h            send-keys -X start-of-line
    bind-key -T copy-mode-vi h              send-keys -X back-to-indentation
    bind-key -T copy-mode-vi \'             send-keys -X end-of-line

    bind-key -T copy-mode-vi /              command-prompt -T search -p "(search)" { send-keys -X search-forward "%%" }
    bind-key -T copy-mode-vi n              send-keys -X search-again
    bind-key -T copy-mode-vi N              send-keys -X search-reverse

    bind-key -T copy-mode-vi \[             send-keys -X history-top
    bind-key -T copy-mode-vi \]             send-keys -X history-bottom
    bind-key -T copy-mode-vi g              command-prompt -p "(goto line)" { send-keys -X goto-line "%%" }

    bind-key -T copy-mode-vi \;             send-keys -X begin-selection
    bind-key -T copy-mode-vi \-             send-keys -X clear-selection
    bind-key -T copy-mode-vi Space          send-keys -X select-line
    bind-key -T copy-mode-vi c              send-keys -X copy-selection-no-clear
