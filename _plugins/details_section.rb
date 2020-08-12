module Jekyll
  class DetailsSectionBlock < Liquid::Block
    def initialize(tag_name, title, tokens)
      super
      @title = title
    end
    require "kramdown"
  
    def render(context)
      text = super

      "<div class='details-box'>
        <div class='details-box-title'>
          <span class='caret'>#{@title}</span>
        </div>
        <div class='nested'>
          #{Kramdown::Document.new(text).to_html}
        </div>
      </div>"
    end
  
  end
end
  
Liquid::Template.register_tag('details_section', Jekyll::DetailsSectionBlock)
  