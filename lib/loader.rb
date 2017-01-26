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
    @cache[@path] = value
  end

  def self.import(id, type=nil)
    chr = id[0]
    if type == 'interop' || (type != 'internal' && !['/', '.'].include?(chr))
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
    if !@cache.include?(@path)
      id = @path.end_with?('.rb') ? @path : "#{@path}.rb"
      Kernel.load(id, true)
    end

    result = @cache[@path]
    @path = prev
    result
  end

  def self.set_basepath(basepath)
    DEBUG.call "Set basepath to #{basepath}"
    @basepath = basepath
  end
end
