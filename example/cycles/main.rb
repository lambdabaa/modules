# Not an rspec test case. This simply makes sure that we
# can use the interop loader to require an external package
# with circular dependencies. The only example I could find
# was 'optparse' and rspec loads that package so this test
# is only useful when run outside of rspec (ie ruby test/interop_cycles.rb).

require_relative '../../lib/modules/interop'

# This goes into an infinite loop without cycle detection.
options = Interop.import('optparse')['OptionParser']
assert = Interop.import('test/unit/assertions')['Test::Unit::Assertions']

assert.assert_equal(options.class, Class)
