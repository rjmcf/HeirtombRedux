module Jekyll
  class DetailsSectionBlock < Liquid::Block
    def initialize(tag_name, unique_id, tokens)
      super
    end
    require "kramdown"
  
    def render(context)
      text = super

      "<div class='details-box'>
        <div class='details-box-title'>
          <span class='caret'>Technical details</span>
        </div>
        <div class='nested'>
          #{Kramdown::Document.new(text).to_html}
        </div>
      </div>"
    end
  
  end
end
  
Liquid::Template.register_tag('details_section', Jekyll::DetailsSectionBlock)
  