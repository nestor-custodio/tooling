# ~/.bashrc: executed by bash(1) for non-login shells.

# Setting the PATH here makes our tooling available to tmux internals.
[ -r "${HOME}/bin/set-path.src" ] && source "${HOME}/bin/set-path.src"

# Setup of interactive shells is handled by our own customizer.
[ -r "${HOME}/custom-shell" ] && source "${HOME}/custom-shell"
