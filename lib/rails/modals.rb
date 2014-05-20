require "rails/modals/version"
raise "rails-modals, not shockingly, requires rails." unless defined?(Rails)
require "rails/modals/engine"
require "rails/modals/railtie"

module Rails
  module Modals
  end
end
