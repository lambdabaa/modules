module Loader
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
    case type
    when 'internal'
      internal_import(id)
    when 'external'
      external_import(id)
    else
      chr = id[0]
      if chr == '/' || chr == '.'
        internal_import(id)
      else
        external_import(id)
      end
    end
  end

  def self.set_basepath(basepath)
    @basepath = basepath
  end

  def self.internal_import(id)
    prev = @path
    if @path.nil?
      raw = File.join(@basepath, id)
    else
      container = File.dirname(@path)
      raw = File.join(container, id)
    end

    @path = File.expand_path(raw)
    require @path
    result = @cache[@path]
    @path = prev
    result
  end

  def self.external_import(id)
    if @cache.include?(id)
      puts "Cache hit #{id}"
      return @cache[id]
    end

    puts "Load #{id}"
    snapshot = Module.constants
    require id
    create_external_module(Module.constants - snapshot)
  end

  def self.create_external_module(new)
    puts "Package definitions #{new}"
    result = package_external_module(new)
    result.each_pair do |key, value|
      Object.send(:remove_const, key.to_sym) unless key.include?('::')
    end

    result
  end

  def self.package_external_module(new, result = {})
    if new.length == 0
      return result
    end

    str = new.pop().to_s
    const = eval str
    if const.nil?
      return package_external_module(new, result)
    end

    if const.respond_to? :constants
      # TODO(ari): Handle circular references!
      children = const.constants.map {|child| "#{str}::#{child.to_s}"}
      new += children
    end

    result[str] = const.class == Module ? Class.new.extend(const) : const
    return package_external_module(new, result)
  end
end
