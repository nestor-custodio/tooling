#! /bin/env bash
source '/home/nestor/bin/std.lib'

# ---
# ---


set-env 'test'
yarn --silent test --passWithNoTests "$@"
