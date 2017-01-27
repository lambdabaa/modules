require_relative './loader'

class Object
  def export(name=nil, value=nil)
    if name.nil?
      value = yield
    else
      value = {name => value}
    end

    Loader.export(value)
  end

  def import(id, type=nil)
    Loader.import(id, type)
  end

  def modules
    Loader::Api
  end
end
