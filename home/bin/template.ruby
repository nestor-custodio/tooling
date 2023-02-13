#! /bin/env ruby-jit

require 'bundler/setup'
Bundler.require :default


... or ...


require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'

  gem '...'
  gem '...', require: %w[...]
end

# ---
# ---


...
