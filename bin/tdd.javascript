#! /bin/env bash
source '/home/nestor/bin/std.lib'

# ---
# ---


load-env 'test'
yarn --silent test --passWithNoTests "$@"
