#! /bin/env bash
source '/home/nestor/bin/std.lib'

# ---
# ---


load-env 'test'
nr test -- --silent --passWithNoTests "$@"
