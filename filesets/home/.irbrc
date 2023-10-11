#! ruby


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


  def db?
    User.take.present?
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


  def my_identities
    {
      # 'sakimorix@gmail.com': { ldap_username: nil,
      #                          password: 'password' },

      'custone@tulsaschools.org': { ldap_username: 'custone',
                                    password: 'password',
                                    employee_id: 59156 }
    }
  end

  def me
    User.where(email: my_identities.keys).take
  end

  def me!
    my_identities.each do |email, identity|
      User.find_or_create_by({ email:            email,
                               role:             :district,
                               has_admin_access: true,
                               name:             'Nestor Custodio',
                               first_name:       'Nestor',
                               last_name:        'Custodio' }.merge identity)
    end

    me
  end


end




## ---
## ---


def gp_time(var = nil)
  gp_local = lambda { |datetime| datetime.in_time_zone 'America/Los_Angeles' }

  case var
    # now
    when nil then gp_local[Time.now]

    # at [datetime]
    when Time, DateTime then gp_local[var]

    # in [duration]
    when ActiveSupport::Duration then gp_local[Time.now] + var

    # like "#h #m #s"
    when String

      duration_method = lambda do |char|
        case char
        when 'w' then :weeks
        when 'd' then :days
        when 'h' then :hours
        when 'm' then :minutes
        when 's' then :seconds
        end
      end

      duration = var.downcase                                                # downcase
                    .split(%r{(?<=[^0-9])(?=[0-9])})                         # create segments
                    .map { |segment| segment.gsub %r{[^0-9a-z]}    , ''   }  # drop non-alphanum
                    .map { |segment| segment.gsub %r{^0+}          , ''   }  # drop leading '0's
                    .map { |segment| segment.gsub %r{([a-z])[a-z]*}, '\1' }  # reduce alpha to single char
                    .select { |segment| segment =~ %r{^[0-9]+[wdhms]$} }     # keep only things that are properly formatted
                    .map { |segment| segment.to_i.send duration_method[segment.last] }  # convert to ActiveSupport::Duration value
                    .sum 0.seconds

      gp_local[Time.now] + duration
  end
end
