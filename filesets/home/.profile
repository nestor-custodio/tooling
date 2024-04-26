# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login exists.


[ -n "$BASH_VERSION" ] && [ -r "${HOME}/.bashrc" ] && source "${HOME}/.bashrc"


# ------------------- #
# BEGIN CUSTOMIZATION #

# Wrap sessions in a Byobu container.
_byobu_sourced='1' source /usr/bin/byobu-launch 2>/dev/null || true
