$define.call do |import|
  add = import.call './add'
  multiply = import.call './multiply'

  {
    add: add,
    multiply: multiply,
  }
end
