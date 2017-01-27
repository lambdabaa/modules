require_relative './debug'
require_relative './interop'

module Loader
  DEBUG = Debug.debug(File.basename(__FILE__))

  # (String) root path for module resolution
  @basepath = '/'

  # (Hash) map from module identifier to resolved module
  @cache = {}

  # (String) path to the file currently being loaded
  @path = nil

  def self.export(value)
    if @cache.include?(@path) && value.class == Hash
      # Special handling to enable multiple exports
      @cache[@path] = @cache[@path].merge(value)
    else
      @cache[@path] = value
    end
  end

  def self.import(id, type=nil)
    if type == 'interop'
      return Interop.import(id)
    end

    prev = @path
    if @path.nil?
      container = @basepath
      raw = File.join(container, id)
    else
      container = File.dirname(@path)
      raw = File.join(container, id)
    end

    @path = File.expand_path(raw)
    filepath = @path.end_with?('.rb') ? @path : "#{@path}.rb"
    exists = File.exist?(filepath)
    if type == 'internal' && !exists
      raise "Could not resolve local module at #{@path}"
    end

    if exists
      # Prefer loading local module since we found it.
      begin
        Kernel.load(filepath, true) unless @cache.include?(@path)
      rescue
        raise LoadError, "Could not load #{filepath} from #{container}"
      end

      result = @cache[@path]
    else
      # Failover to external load.
      result = Interop.import(id)
    end

    @path = prev
    result
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

    def self.config(opts)
      if opts.include?(:basepath)
        Loader.instance_variable_set :@basepath, opts[:basepath]
      end
    end
  end
end
