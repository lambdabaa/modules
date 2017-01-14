$define.call do |import|
  def reverse(str, result='')
    if str.length == 0
      result
    else
      reverse(str[1..-1], str[0] + result)
    end
  end
end
