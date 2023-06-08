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
	bind-key -n M-Space command-prompt -p "#[bold] (shell command)" "run-shell 'blindly %%'"
	
	## Allow in-context tmux command execution.
	bind-key -n M-x command-prompt -p "#[bold] (tmux command)" "%%"

	## Reload Profile.
	bind-key -n M-` source $BYOBU_PREFIX/share/byobu/profiles/tmuxrc




## Session Management

  bind-key -n M-C-m    new-session

  bind-key -n M-,      switch-client -p
  bind-key -n M-.      switch-client -n

  bind-key -n M-C-d    confirm-before -p "#[bold] Detach From Session?" detach
  bind-key -n M-C-q    confirm-before -p "#[bold] Close All Windows In Session?" kill-session




## Window Management

  bind-key -n M-C-n    new-window -c "#{pane_current_path}" \; rename-window "-"
  bind-key -n M-n      new-window -c "#{pane_current_path}" \; rename-window "-"

  bind-key -n M-u      previous-window
  bind-key -n M-o      next-window

  bind-key -n M-C-u    swap-window -t -1 \; select-window -t -1
  bind-key -n M-C-o    swap-window -t +1 \; select-window -t +1

  bind-key -n M-C-r    command-prompt -p "#[bold] (rename-window)" "rename-window '%%'"
  bind-key -n M-C-\\   confirm-before -p "#[bold] Close Window (And All Panes)?" kill-window




## Pane Management/Navigation

  bind-key -n M-]      split-window -h -c "#{pane_current_path}"
  bind-key -n M-[      split-window -v -c "#{pane_current_path}"
  bind-key -n M-p      confirm-before -p "#[bold] Pop Out This Pane (Into Its Own Window)?" break-pane

  bind-key -n M--      select-pane -M
  bind-key -n M-=      select-pane -m
  bind-key -n M-BSpace swap-pane

  bind-key -n M-i      select-pane -U
  bind-key -n M-k      select-pane -D
  bind-key -n M-j      select-pane -L
  bind-key -n M-l      select-pane -R

  bind-key -n M-C-i    resize-pane -U
  bind-key -n M-C-k    resize-pane -D
  bind-key -n M-C-j    resize-pane -L
  bind-key -n M-C-l    resize-pane -R

  bind-key -n M-/      choose-tree -Z
  bind-key -n M-z      resize-pane -Z
  bind-key -n M-a      set -w synchronize-panes

  bind-key -n M-r      command-prompt -p "#[bold] (rename-pane)" "select-pane -T '%%'"
  bind-key -n M-\'     kill-pane


  ## Scroll Mode
  bind-key -n M-s copy-mode


  ## Capture Scroll Buffer
  bind-key -n M-c capture-pane -S -32768 \; save-buffer "$BYOBU_RUN_DIR/printscreen" \; delete-buffer \; new-window -n "PRINTSCREEN" "$BYOBU_EDITOR $BYOBU_RUN_DIR/printscreen"
