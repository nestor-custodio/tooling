#! /bin/env bash
source '/home/nestor/bin/std.lib'

# ---
# ---


export RUBY_ENV='test'
export RAILS_ENV='test'
export RACK_ENV='test'
export NODE_ENV='test'


yarn --silent test --passWithNoTests "$@"
