Gem::Specification.new do |spec|
  spec.name = 'modules'
  spec.version = '0.2.0'
  spec.date = '2017-01-26'
  spec.summary = 'Port of js module loader to ruby'
  spec.description = 'A Ruby module loader inspired by the semantics of js modules'
  spec.executables << 'modules'
  spec.files = [
    'lib/debug.rb',
    'lib/global.rb',
    'lib/interop.rb',
    'lib/loader.rb',
    'lib/modules.rb',
  ]
  spec.authors = ['Gareth (Ari) Aye']
  spec.email = 'gareth@alumni.middlebury.edu'
  spec.homepage = 'https://github.com/lambdabaa/modules'
  spec.license = 'MIT'
end
