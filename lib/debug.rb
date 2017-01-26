module Debug
  @enabled = false

  def self.enable(value)
    @enabled = !!value
  end

  def self.debug(topic)
    lambda do |msg|
      puts "[#{topic}] #{msg}" if @enabled
    end
  end
end
