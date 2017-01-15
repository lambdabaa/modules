module RequireRb
  # (String) root path for module resolution
  @basepath = '/'

  # (Hash) map from module identifier to resolved module
  @cache = {}

  def self.internal_import(dirname, basename)
    path = File.join @basepath, dirname, basename

    $import = ->(name) {
      if name[0] == '.'
        # Treat as local module.
        child_path = File.join dirname, name[1..-1]
        child_dirname = File.dirname child_path
        child_basename = File.basename child_path
        internal_import child_dirname, child_basename
      else
        # Treat as external ruby import.
        external_import name
      end
    }

    $define = ->(&blk) {
      @cache[path] = blk.call($import)
    }

    if @cache.include? path
      puts "Already cached local module #{path}"
      return @cache[path]
    end

    puts "Loading local module #{path}"
    require path
    return @cache[path]
  end

  def self.external_import(name)
    if @cache.include? name
      puts "Already cached external module #{name}"
      return @cache[name]
    end

    sym = name.to_sym
    if Module.constants.include? sym
      puts "Already loaded external module #{name}"
      resolved = eval name
      @cache[name] = resolved
      return resolved
    end

    puts "Loading external module #{name}"
    snapshot = Module.constants
    require name
    defined = Module.constants - snapshot
    plucked = []
    resolved = {}
    while defined.length > 0
      todo = defined.pop
      plucked.push(todo)
      str = todo.to_s
      const = eval str
      next if const.nil?
      resolved[str] = const.class == Module ? Class.new.extend(const) : const
      if const.respond_to? :constants
        defined += const.constants.map {|child| "#{str}::#{child.to_s}"}
      end
    end

    puts "Found #{resolved}"
    @cache[name] = resolved
    plucked.each {|item| Object.send(:remove_const, item)}
    return resolved
  end

  def self.run(args, opts)
    file = args[0]
    abs = "#{Dir.pwd}/#{file}"
    dirname = File.dirname abs
    basename = File.basename abs

    puts "Set default basepath to #{dirname}"
    @basepath = dirname
    internal_import '', basename
  end

  def self.main(cmd, args, opts)
    case cmd
    when 'run'
      run(args, opts)
    else
      raise "Invalid command #{cmd}"
    end
  end
end
