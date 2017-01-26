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
    chr = id[0]
    if type == 'interop'
      return Interop.import(id)
    end

    prev = @path
    if @path.nil?
      raw = File.join(@basepath, id)
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
      Kernel.load(filepath, true) unless @cache.include?(@path)
      result = @cache[@path]
    else
      # Failover to external load.
      result = Interop.import(id)
    end

    @path = prev
    result
  end

  def self.set_basepath(basepath)
    DEBUG.call "Set basepath to #{basepath}"
    @basepath = basepath
  end
end
