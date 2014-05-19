$: << File.dirname(__FILE__)
require 'helpers/view_helpers'

module Rails::Modals
  class Railtie < Rails::Railtie
    initializer "rails_modals.view_helpers" do
      ActionView::Base.send :include, ViewHelpers
    end
  end
end
