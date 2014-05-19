require "rails/modals/version"
require "rails/modals/engine" if ::Rails.version >= '3.1'
require "rails/modals/railtie" if defined?(Rails)

module Rails
  module Modals
  end
end
