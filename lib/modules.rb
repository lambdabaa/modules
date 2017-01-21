module Modules
  # (String) root path for module resolution
  @basepath = '/'

  # (Hash) map from module identifier to resolved module
  @cache = {}

  # (String) most recent directory that import was invoked on
  @dirname = '/'

  # (String) most recent path that import was invoked on
  @path = '/'

  def self.internal_import(dirname, basename)
    path = File.join @basepath, dirname, basename
    if @cache.include? @path
      puts "Already cached local module #{path}"
      return @cache[path]
    end

    puts "Loading local module #{path}"
    prev_dirname = @dirname
    prev_path = @path
    @dirname = dirname
    @path = path
    require @path
    @dirname = prev_dirname
    @path = prev_path
    return @cache[path]
  end

  def self.external_import(name)
    if @cache.include? name
      puts "Already cached external module #{name}"
      return @cache[name]
    end

    puts "Loading external module #{name}"
    snapshot = Module.constants
    require name
    defined = Module.constants - snapshot
    plucked = []
    resolved = {}
    while defined.length > 0
      todo = defined.pop
      plucked.push todo
      str = todo.to_s
      const = eval str
      next if const.nil?
      resolved[str] = const.class == Module ? Class.new.extend(const) : const
      if const.respond_to? :constants
        children = const
          .constants
          .map {|child| "#{str}::#{child.to_s}"}
          .select {|id|
            parts = id.split '::'
            groups = parts.group_by {|x| x}
            groups.values.all? {|group| group.length < 3}
          }

        defined += children
      end
    end

    puts "Found #{resolved}"
    @cache[name] = resolved
    plucked
      .select {|item| item.class == Symbol}
      .each {|item| Object.send(:remove_const, item)}
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

class Object
  def export
    cache = Modules.instance_variable_get :@cache
    path = Modules.instance_variable_get :@path
    cache[path] = yield
  end

  def import(name)
      if name[0] == '.'
        # Treat as local module.
        dirname = Modules.instance_variable_get :@dirname
        child_path = File.join dirname, name[1..-1]
        child_dirname = File.dirname child_path
        child_basename = File.basename child_path
        Modules.internal_import child_dirname, child_basename
      else
        # Treat as external ruby import.
        Modules.external_import name
      end
  end
end
