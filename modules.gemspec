lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name = 'modules'
  spec.version = '1.1.1'
  spec.date = '2017-01-27'
  spec.summary = 'Port of js module loader to ruby'
  spec.description = 'A Ruby module loader inspired by the semantics of js modules'
  spec.executables << 'modules'
  spec.files = Dir.glob('lib/**/*.rb')
  spec.require_paths = ['lib']
  spec.authors = ['Gareth (Ari) Aye']
  spec.email = 'gareth@alumni.middlebury.edu'
  spec.homepage = 'https://github.com/lambdabaa/modules'
  spec.license = 'MIT'
end
