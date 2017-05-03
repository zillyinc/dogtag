lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'icicle/version'

Gem::Specification.new do |s|
  s.name = 'icicle'
  s.version = Icicle::VERSION
  s.summary = 'A Ruby implementation of the Icicle ID generation system'
  s.description = 'Generate unique IDs with Redis for distributed systems'
  s.files = Dir['README.*', 'MIT-LICENSE', 'lib/**/*.rb', 'lua/**/*.lua']
  s.require_path = 'lib'
  s.author = 'Adam Crownoble'
  s.email = 'adam@codenoble.com'
  #s.homepage = 'https://github.com/?'
  #s.license = 'MIT'
  s.add_dependency('redis', '~> 3.3')
end
