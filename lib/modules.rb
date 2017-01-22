require_relative './loader'

module Modules
  def self.run(args, opts)
    file = args[0]
    abs = "#{Dir.pwd}/#{file}"
    Loader.set_basepath(File.dirname(abs))
    Loader.import(File.basename(abs), 'internal')
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