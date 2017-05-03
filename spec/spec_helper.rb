require 'bundler/setup'
require 'rspec'
require 'icicle'

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
end
