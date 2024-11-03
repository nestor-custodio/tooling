#! /bin/env ruby


## --- KERNEL-LEVEL STUFF ---
## --------------------------


module Ruby; end
Object.constants
      .grep(%r{^RUBY_}, &:to_s)
      .map { |name| { constant: name, method: name.delete_prefix('RUBY_').downcase } }
      .each { |spec| Ruby.define_singleton_method(spec[:method]) { Object.const_get spec[:constant] } }

def Ruby.repl_engine
  @repl_engine ||= begin
    engine = ([$0] & ['irb', 'pry']).pop
    engine ||= (defined? Pry) ? 'pry' : 'irb'

    engine.freeze
  end
end


## ---


def gem!(*entries, **gems_with_requires)
  require 'bundler/inline'
  require 'uri'

  entries = [entries].flatten.map(&:to_s) # Normalize *entries.
  sources = entries.select { |entry| URI(entry).scheme rescue nil }
  gem_list = (entries - sources).map { |name| { name: name, require: name } }
  gem_list += gems_with_requires.map do |name, requires|
                [requires].flatten.map do |require|
                  { name: name.to_s, require: require.to_s }
                end
              end

  gem_list.flatten!
  gem_list.select! do |gem_spec|
    require gem_spec[:require]
    false
  rescue LoadError
    true
  end

  return if gem_list.empty?

  gemfile do
    source 'https://rubygems.org'
    sources.each { |addy| source addy }
    gem_list.each { |gem_spec| gem gem_spec[:name], require: gem_spec[:require] }
  end
end


## ---


gem! :date
gem! :time
gem! activesupport: %w[active_support active_support/core_ext] unless defined? ActiveSupport


def timestamp
  Time.now.to_f
end


def indifferent_hash
  {}.indifferent
end




## --- REPL APPEARANCE ---
## -----------------------


  ## --- AWESOMEPRINT ---


  gem! :awesome_print

  AwesomePrint.defaults = {

    # General formatting.
    plain:         false ,  # B/W text only?
    html:          false ,  # Use HTML instead of ANSI color codes?
    multiline:     true  ,  # Display in multiple lines?
    indent:        2     ,  # Number of spaces for indenting.
    raw:           false ,  # Recursively format instance variables? (Warning: this does not do what you probably expect.)

    # Identifiers.
    object_id:     true  ,  # Show object ID (`#object_id`)?
    class_name:    :class,  # Method name to `#send` for the instance class name. (e.g. `:to_s`)

    # Enumeration.
    ruby19_syntax: false ,  # Use Ruby 1.9 hash syntax in output?
    index:         true  ,  # Display array indices?
    sort_keys:     true  ,  # Sort hash keys?
    sort_vars:     true  ,  # Sort instance variables?
    limit:         100   ,  # Array/hash element limit.


    color: { args:       :pale     ,
             array:      :white    ,
             bigdecimal: :blue     ,
             class:      :yellow   ,
             date:       :greenish ,
             falseclass: :red      ,
             integer:    :blue     ,
             float:      :blue     ,
             hash:       :pale     ,
             keyword:    :cyan     ,
             method:     :purpleish,
             nilclass:   :red      ,
             rational:   :blue     ,
             string:     :yellowish,
             struct:     :pale     ,
             symbol:     :cyanish  ,
             time:       :greenish ,
             trueclass:  :green    ,
             variable:   :cyanish    }

  }

  AwesomePrint.send "#{Ruby.repl_engine}!"


  ## --- MONKEYPATCHES ---


  def set_autocompletion(state)
    return unless defined? Reline

    case state
      when :on , true  then Reline.autocompletion = true
      when :off, false then Reline.autocompletion = false
      else raise ArgumentError, "unexpected 'state': #{state.inspect}"
    end
  end

  def auto = set_autocompletion :on
  def noauto = set_autocompletion :off




## --- BASE-LEVEL MONKEYPATCHES ---
## --------------------------------


class Object
  def own_methods
    public_methods false
  end

  def real_methods
    return public_methods if self.instance_of? Object
    public_methods - Object.methods
  end
end


class Numeric
  def whole?
    remainder(1).zero?
  end
end


class String
  def to_date(*args, **kwargs, &block)
    Date.parse(self, *args, **kwargs, &block)
  end

  def to_time(*args, **kwargs, &block)
    Time.parse(self, *args, **kwargs, &block)
  end

  def to_datetime(*args, **kwargs, &block)
    DateTime.parse(self, *args, **kwargs, &block)
  end

  def is
    inquiry
  end
end


class Symbol
  def is
    to_s.inquiry
  end
end


class Hash
  def indifferent
    with_indifferent_access
  end

  def stratify
    raise LoadError unless defined? Rack::QueryParser

    output = {}
    parser = Rack::QueryParser.new Hash, nil, nil
    each { |key, value| parser.normalize_params output, key, value, 100 }

    output
  end

  def stratify!
    raise LoadError unless defined? Rack::QueryParser

    original_data = dup
    clear
    parser = Rack::QueryParser.new Hash, nil, nil
    original_data.each { |key, value| parser.normalize_params self, key, value, 100 }

    self
  end
end


module Enumerable
  def each_with_array(&block)
    each_with_object([], &block)
  end

  def each_with_hash(&block)
    each_with_object({}, &block)
  end

  def each_with_indifferent_hash(&block)
    each_with_object(indifferent_hash, &block)
  end

  alias :ewo :each_with_object
  alias :ewa :each_with_array
  alias :ewh :each_with_hash
  alias :ewi :each_with_indifferent_hash
end




## --- RAILS ---
## -------------
if defined? Rails


  ## --- MONKEYPATCHES ---


  module ActiveRecord
    module ModelSchema
      module ClassMethods
        def cols(*metadata)
          metadata = [:type] unless metadata.present?

          hash = columns.ewi { |column, out| out[column.name] = metadata.ewi { |md, out| out[md] = column.send(md.to_sym) } }
          hash.transform_values! { |value| value.values.first } if metadata.length == 1

          hash
        end

        def col(name, *metadata)
          name = name.to_s
          name = attribute_aliases[name] if attribute_aliases.has_key? name

          cols(*metadata)&.dig name
        end
      end
    end
  end


  ## --- MIGRATION MANAGEMENT ---


  def lazy_migrate
    gem! :lazy_migrate
    LazyMigrate.run
  end

  alias :db! :lazy_migrate


  ## --- FACTORYBOT HELPERS ---


  if defined? FactoryBot

    def attributes_for(model, *args)
      gem! :factory_bot
      FactoryBot.attributes_for model, *args
    rescue LoadError
    end

    def build(model, *args)
      gem! :factory_bot
      FactoryBot.build model, *args
    rescue LoadError
    end

    def create(model, *args)
      gem! :factory_bot
      FactoryBot.create model, *args
    rescue LoadError
    end

  end


  ## --- GENERAL HELPERS ---


  def urls
    Rails.application.routes.url_helpers
  end


  def db?
    User.take
    true
  rescue StandardError
    false
  end

  def connection
    ApplicationRecord.connection
  end

  def reconnect!
    connection.reconnect! unless connection.active?
    connection.clear_cache!
  end

  def clear_cache!
    connection.clear_cache!
  end
  alias clear_db_cache! clear_cache!


end
