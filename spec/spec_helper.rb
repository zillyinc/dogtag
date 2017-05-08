require 'bundler/setup'
require 'rspec'
require 'dogtag'

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
end
