requirerb
=========

A proof-of-concept Ruby module loader inspired by the semantics of
the [amd api](https://github.com/amdjs/amdjs-api/wiki/AMD)!

[![Build Status](https://travis-ci.org/lambdabaa/requirerb.png?branch=master)](https://travis-ci.org/lambdabaa/requirerb)

### Why

One of Ruby's greatest weaknesses is that it lacks a good mechanism
for named imports and exports. When you `require` a ruby file, its
declarations (classes, modules, etc) get evaluated into your scope.
In contrast, the node.js commonjs module system allows developers
to explicitly declare module exports that consumers can access on
the loaded module object. Many prefer the explicit and isolated aspects
of js modules. This experiment strives to demonstrate a cleaner modules
abstraction for Ruby that maintains some interoperability with existing
practices in the Ruby standard library and community packages.

### API

#### define(&blk)

Declare a module (one per file) that other modules can load by calling `import`
with a relative filepath. `define` takes a single block parameter whose return
value is what gets exported from the module.

#### import(id)

Load another module. `import` works with local modules declared with `define` as
well as other Ruby libraries that declare constants like classes and modules. In
the latter case when loading external libraries, you need to provide the module name
as the `id` parameter and `import` will return a `Hash` containing all constants
declared. For instance

```
import('test/unit/assertions') => 

{
  "Test"=>#<Class:0x00000001d08f58>,
  "Test::Unit"=>#<Class:0x00000001ab38c0>,
  "Test::Unit::Assertions"=>#<Class:0x00000001ab29e8>,
  ...
}
```

### Example (alpha syntax)

```rb
### foo.rb
define do
  # The value you return from the define block is what gets exported
  # from the module.
  'foo'
end

### foo_wrapper.rb
define do
  # Load the 'foo' constant from foo.rb
  foo = import './foo'

  def wrapper
    foo
  end
end

### test.rb
# load local modules defined with an amd-inspired syntax
foo = import './foo_wrapper'
# compatible with external globals-style ruby modules
assert = import('test/unit/assertions')['Test::Unit::Assertions']

assert.assert_equal(foo.foo(), 'foo')
# No global namespace pollution \o/
assert.assert_equal(defined? Test, nil)
```
