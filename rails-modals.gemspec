# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails/modals/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-modals"
  spec.version       = Rails::Modals::VERSION
  spec.authors       = ["Colin Young"]
  spec.email         = ["me@colinyoung.com"]
  spec.summary       = %q{Turn your links to Rails forms into modals!}
  spec.description   = %q{Takes links to :new or :edit pages and displays their forms inline in a Backbone modal.}
  spec.homepage      = "https://github.com/colinyoung/rails-modals"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "sprockets-rails"
  spec.add_development_dependency "jquery-rails"
  spec.add_development_dependency "turbolinks"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "poltergeist"
  spec.add_development_dependency "active_hash"
  spec.add_dependency "railties"
end
