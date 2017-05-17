lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'dogtag/version'

Gem::Specification.new do |s|
  s.name = 'dogtag'
  s.version = Dogtag::VERSION
  s.summary = 'A Redis-powered Ruby ID generation client'
  s.description = 'Generate unique IDs with Redis for distributed systems, based heavily off of Icicle and Twitter Snowflake'
  s.files = Dir['README.*', 'MIT-LICENSE', 'lib/**/*.rb', 'lua/**/*.lua.erb']
  s.require_path = 'lib'
  s.author = 'Adam Crownoble'
  s.email = 'adam@codenoble.com'
  s.homepage = 'https://github.com/zillyinc/dogtag'
  #s.license = 'MIT'
  s.add_dependency('redis', '~> 3.3')
  s.add_development_dependency('rspec', '~> 3.5')
end
