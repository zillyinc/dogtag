require 'bundler/setup'
require 'rspec'
require 'date'
require 'dogtag'

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
end
