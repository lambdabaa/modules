$define.call do |import|
  def ok(predicate, msg)
    msg = msg || "Expected #{predicate} to be truthy"

    if (!predicate)
      raise new Error(msg)
    end
  end

  def equal(one, other)
    ok(one == other, "Expected #{one} to equal #{other}")
  end


  {
    equal: equal,
    ok: ok,
  }
end
