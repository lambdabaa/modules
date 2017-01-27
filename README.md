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

### Installation

`bundle install modules`

### Usage within Ruby

```rb
require 'modules'

# Now import and export are available globally throughout your program.
two = import('./two')

# import also hangs off of the modules global if you prefer
two = modules.import('./two')

export do
  two + two
end
```

### Bootstrapping from the command line

You can run your program through the `modules` command-line interface
via `modules run <path/to/main.rb>`. This invocation style doesn't
require your program to load the gem; `main.rb` can use `import` to load
local modules defined with `export` as well as other ruby libraries.

### API

#### export(&blk)

Declare a module (one per file) that other modules can load by calling `import`
with a relative filepath. `export` takes a single block parameter whose return
value is what gets exported from the module.

#### export(key, value)

Declare a single export from a module. This will make it so that your
module exports a hash with `{key => value}`. You can call this multiple times
in a module.

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

#### modules.config(options)

Configure the loader with an options hash. Currently supports

`:basepath` - base directory that the loader uses for filepath resolution

### Example

```rb
### consts.rb
export :foo, 'foo'
export :bar, 'bar'

### foobar.rb
# Load the constants from consts.rb
consts = import './consts'

export do
  lambda { consts[:foo] + consts[:bar] }
end

### test.rb
# load local modules defined with an amd-inspired syntax
foobar = import './foobar'
# compatible with external globals-style ruby modules
assert = import('test/unit/assertions')['Test::Unit::Assertions']

assert.assert_equal(foobar.call(), 'foobar')
# No global namespace pollution \o/
assert.assert_equal(defined? Test, nil)
```

### Resolution algorithm

When `import('bar/baz')` is called from /home/lambdabaa/foo, `modules`
will build /home/lambdabaa/foo/bar/baz (currently by composing
`File.expand_path` and `File.join`) and check whether this file exists.
If it does, `modules` will assume this is a local import. Otherwise,
it will assume `bar/baz` isn't a locally defined module and will try
`require('bar/baz')`.

### Wat?

I'm glad you asked! Under the hood we load code into the modules cache
using [Kernel#load](https://ruby-doc.org/core-2.4.0/Kernel.html#method-i-load)
with `wrap=true`. The interop layer's implementation is currently a bit sketchy
and relies on comparing snapshots of `Module.constants` before and after issuing
a `require` for a core lib or external package.
