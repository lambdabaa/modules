export do
  reverse = lambda do |str, result=''|
    if str.length == 0
      result
    else
      reverse.call(str[1..-1], str[0] + result)
    end
  end

  reverse
end
