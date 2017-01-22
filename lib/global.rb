require_relative './loader'

class Object
  def export
    value = yield
    Loader.export(value)
  end

  def import(id)
    Loader.import(id)
  end
end
