modules
=======

A Ruby module loader inspired by the semantics of js modules.

[![Gem Version](https://badge.fury.io/rb/modules.svg)](https://badge.fury.io/rb/modules)
[![Build Status](https://travis-ci.org/lambdabaa/modules.png?branch=master)](https://travis-ci.org/lambdabaa/modules)

### Motivation

One of Ruby's greatest weaknesses is that it lacks a good mechanism
for named imports and exports. When you `require` a ruby file, its
declarations (classes, modules, etc) get evaluated into your scope.
In contrast, the node.js commonjs module system allows developers
to explicitly declare module exports that consumers can access on
the loaded module container. Many prefer the explicit and isolated aspects
of js modules. This experiment strives to demonstrate a cleaner modules
abstraction for Ruby that maintains some interoperability with existing
practices in the Ruby standard library and community packages.

### Command-line usage

```
bundle install modules
modules run <path/to/main.rb>
```

In the example above, `main.rb` will be able to import local modules that use
`export` as well as other ruby libraries.

### API

#### export(&blk)

Declare a module (one per file) that other modules can load by calling `import`
with a relative filepath. `export` takes a single block parameter whose return
value is what gets exported from the module.

#### import(id)

Load another module. `import` works with local modules declared with `export` as
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

### Example

```rb
### foo.rb
export do
  # The value you return from the export block is what gets exported
  # from the module.
  'foo'
end

### foo_wrapper.rb
# Load the 'foo' constant from foo.rb
foo = import './foo'

export do
  lambda { foo }
end

### test.rb
# load local modules defined with an amd-inspired syntax
foo = import './foo_wrapper'
# compatible with external globals-style ruby modules
assert = import('test/unit/assertions')['Test::Unit::Assertions']

assert.assert_equal(foo.call(), 'foo')
# No global namespace pollution \o/
assert.assert_equal(defined? Test, nil)
```
