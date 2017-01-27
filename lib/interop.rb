require 'set'

require_relative './debug'

module Interop
  DEBUG = Debug.debug(File.basename(__FILE__))

  # (Hash) map from module identifier to resolved module
  @cache = {}

  def self.import(id, opts={})
    if @cache.include?(id)
      DEBUG.call "Cache hit #{id}"
      return @cache[id]
    end

    DEBUG.call "Load #{id}"
    snapshot = Module.constants
    require id
    cleanly_load(Module.constants - snapshot, opts)
  end

  def self.cleanly_load(targets, opts)
    DEBUG.call "Package definitions #{targets}"
    result = wrap_constants(targets)
    if !opts[:save_the_environment]
      result.each_pair do |key, value|
        Object.send(:remove_const, key.to_sym) unless key.include?('::')
      end
    end

    result
  end

  def self.wrap_constants(new, result={}, visited=Set.new)
    if new.length == 0
      return result
    end

    str = new.pop().to_s
    const = eval str
    if const.nil?
      return wrap_constants(new, result)
    end

    if const.respond_to? :constants
      children = const
        .constants
        .reject {|element| visited.include?(element)}
        .map {|child|
          visited.add(child)
          "#{str}::#{child.to_s}"
        }

      new += children
    end

    result[str] = const.class == Module ? Class.new.extend(const) : const
    return wrap_constants(new, result, visited)
  end
end
