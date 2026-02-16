require 'simplecov'
SimpleCov.start

require File.expand_path('dummy/config/environment', __dir__)

require 'active_support'
require 'bigdecimal'
require 'date'

require 'action_controller'
require 'rails_simple_params'
require 'rspec/rails'
Dir['./spec/rails_simple_params/validator/shared_examples/**/*.rb'].each { |f| require f }
