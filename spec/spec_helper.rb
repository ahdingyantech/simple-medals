require 'bundler/setup'
require 'pry'
require 'rspec'
require 'simple-medals'
require 'active_record'
require 'support/database'
require 'factory_girl'
require 'database_cleaner'
FactoryGirl.find_definitions
require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|
  config.order = "random"

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
