#! /bin/env ruby

# ------------- #
# -- STD Lib -- #

require 'bundler/inline'
require 'pathname'

# ----------------- #
# -- Gem Loaders -- #

gemfile do
  source 'https://rubygems.org'
  gem 'optimist'

  # gem '...', require: %w[...]
end

# ------------------ #
# -- Misc Helpers -- #

SCRIPT_TIMESTAMP = Time.now.to_f
def script_duration = (Time.now.to_f - SCRIPT_TIMESTAMP)

def script_file = Pathname.new(__FILE__)

def script_path = script_file.dirname
def script_real = script_file.realpath
def script_name = script_file.basename

def file_blanks = (' ' * script_file.to_s.length)
def path_blanks = (' ' * script_path.to_s.length)
def real_blanks = (' ' * script_real.to_s.length)
def name_blanks = (' ' * script_name.to_s.length)

# --------------- #
# -- Help Text -- #

usage = <<~USAGE
  Usage: #{script_name} ...
         #{name_blanks} ...

  Brief description.


  Mandatory arguments to long options are mandatory for short options too.
    --help                    Show this help text.


  Exit Status:
    0  if OK,
    1  if invalid option.
USAGE

$stdout.write usage and exit if ARGV.intersect? %w[-h --help]

# ----------------------------------- #
# -- Parameter Processing: Options -- #

options = Optimist.options do
  # https://www.manageiq.org/optimist/

  opt :option_a, 'description A', short: :a # Boolean
  opt :option_b, 'description B', short: :b, default: ''

  # ---

  either :option_a, :option_b, *more # EXACTLY ONE of these MUST be given.
  depends :option_a, :option_b, *more # This is a set; use is ALL or NONE.
  conflicts :option_a, :option_b, *more # AT MOST ONE of these MAY be given.
end

# --------------------------------------- #
# -- Parameter Processing: Positionals -- #

non_option_var_a = ARGV.shift
Optimist.die '...', 1 unless ___?

non_option_var_b = ARGV.shift
Optimist.die '...', 1 unless ___?

Optimist.die 'invalid option(s)', 1 unless ARGV.empty?

# ----------------------------------------- #
# -- Parameter Processing: Sanity Checks -- #

Optimist.die :option_a, '...' unless ___?
Optimist.die :option_b, '...' unless ___?

# ---
# ---

my_command
