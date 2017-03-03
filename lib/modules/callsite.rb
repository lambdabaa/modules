module Callsite
  # Prefer caller_locations since it's faster, but failover to caller
  # since caller_locations was only introduced in v2.0.0.
  def self.resolve(idx=1)
    defined?(caller_locations) ?
      caller_locations[idx + 1].absolute_path :
      caller[idx + 1].split(':').first
  end
end
