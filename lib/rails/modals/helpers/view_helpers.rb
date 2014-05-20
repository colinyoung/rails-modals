module Rails::Modals
  module ViewHelpers

    def setup_modals
      @modals ||= []
    end

    def link_to_modal *args, &block
      setup_modals

      options = args.extract_options!
      options["data-open-modal"] ||= ''

      text = args.shift unless block_given?

      path = if args.first.is_a? Symbol
        path_helper = args.shift
        self.send *[path_helper].concat(args)
      else
        args.shift
      end

      queue_modal! path

      options["data-path"] ||= path

      if text
        link_to text, path, options
      else
        link_to path, options, &block
      end
    end

    def queue_modal! path
      @modals << path
    end

    def modals
      scripts = @modals.collect do |modal|
        content_tag :script, type: "text/template", :"data-path" => modal do
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
