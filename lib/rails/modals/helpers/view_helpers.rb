module Rails::Modals
  module ViewHelpers

    def setup_modals
      @modals ||= {}
    end

    def link_to_modal *args, &block
      setup_modals

      options = args.extract_options!
      options["data-open-modal"] ||= ''

      text = args.shift unless block_given?

      path = args.shift

      queue_modal! path, options

      options["data-path"] ||= path

      if text
        link_to text, path, options
      else
        link_to path, options, &block
      end
    end

    def queue_modal! path, options
      @modals[path] = options unless @modals.has_key? path
    end

    def modals
      scripts = @modals.collect do |path, options|
        attributes = { type: "text/template", :"data-path" => path }
        attributes[:"data-remote-modal"] = true if options[:remote]
        content_tag :script, attributes do
          raw <<-RAW
            <div class="bbm-modal__topbar">
              <h3 class="bbm-modal__title"><%= title %></h3>
              <a href="javascript:;" class="bbm-button cancel" style="display: none">&times; Cancel</a>
            </div>
            <div class="bbm-modal__section">
              <%= content %>
            </div>
            <div class="bbm-modal__bottombar">
              <a href="javascript:;" class="bbm-button close">Close</a>
              <a href="javascript:;" class="bbm-button previous" style="display: none">Previous</a>          
              <a href="javascript:;" class="bbm-button next" style="display: none">Next</a>
            </div>
          RAW
        end
      end

      raw scripts.join("\n")
    end

    def modals?
      defined? @modals
    end
  end
end
