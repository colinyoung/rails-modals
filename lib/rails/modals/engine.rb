module Rails
  module Modals
    # This engine causes assets in vendor/assets to be loaded automatically by sprockets in the parent rails app
    class Engine < ::Rails::Engine
    end
  end
end