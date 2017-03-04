require_relative './callsite'
require_relative './debug'
require_relative './interop'

module Loader
  DEBUG = Debug.debug(File.basename(__FILE__))

  # (String) root path for module resolution
  @basepath = '/'

  # (Hash) map from module identifier to resolved module
  @cache = {}

  # (Boolean) Whether or not import has been called at least once.
  @import_called = false

  # (Boolean) whether to purge constants added to global namespace on interop load
  @save_the_environment = false

  def self.export(value)
    callsite = Callsite.resolve
    if @cache.include?(callsite) && value.class == Hash
      # Special handling to enable multiple exports
      @cache[callsite] = @cache[callsite].merge(value)
    else
      @cache[callsite] = value
    end
  end

  def self.import(id, type=nil)
    if type == 'interop'
      return Interop.import(id, save_the_environment: @save_the_environment)
    end

    filepath, exists, parent = resolve_callsite(id)

    if type == 'internal' && !exists
      raise "Could not resolve local module at #{path}"
    end

    if exists
      # Prefer loading local module since we found it.
      begin
        Kernel.load(filepath, true) unless @cache.include?(filepath)
      rescue => e
        raise LoadError, "Could not load #{filepath} from #{parent}: #{e}"
      end

      return @cache[filepath]
    end

    # Failover to external load.
    return Interop.import(id, save_the_environment: @save_the_environment)
  end

  def self.delete(id)
    filepath, exists = resolve_callsite(id)
    @cache.delete(exists ? filepath : id)
  end

  module Api
    def self.import(id, type=nil)
      Loader.import(id, type)
    end

    def self.export(name=nil, value=nil)
      if name.nil?
        value = yield
      else
        value = {name => value}
      end

      Loader.export(value)
    end

    def self.delete(id)
      Loader.delete(id)
    end

    def self.config(opts)
      [
        :basepath,
        :save_the_environment,
      ].each do |opt|
        Loader.instance_variable_set("@#{opt}", opts[opt]) if opts.include?(opt)
      end
    end
  end

  private

  def self.resolve_callsite(id)
    callsite = Callsite.resolve(2)
    parent = @import_called ? File.dirname(callsite) : @basepath
    raw = File.join(parent, id)
    path = File.expand_path(raw)
    filepath = path.end_with?('.rb') ? path : "#{path}.rb"
    exists = File.exist?(filepath)
    [filepath, exists, parent]
  end
end
