# load local modules defined with an amd-inspired syntax
modular = import('./modular')
# compatible with external globals-style ruby modules
assert = import('test/unit/assertions')['Test::Unit::Assertions']

assert.assert_equal(modular[:add].call(2, 3, 2), 1)
assert.assert_equal(modular[:multiply].call(8, 7, 10), 6)
