ENV['RAILS_ENV'] ||= 'test'

%x[bower install] # Ensure bower files are installed

require 'rspec'
require 'yaml'
require 'capybara/rspec'

# require the rails app
require 'support/mock_rails/config/environment'

# require rails_modals
require 'rails/modals'

require 'capybara/poltergeist'
Capybara.app = MockRails::Application
Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  config.order = "random"
end
