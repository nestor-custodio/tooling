#! /bin/env bash
source '/home/nestor/bin/std.lib'

# ---
# ---


load-env 'test'
ding-if-slow yarn --silent test --passWithNoTests "$@"
