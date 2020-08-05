module Jekyll
  class InfoBoxBlock < Liquid::Block
    def initialize(tag_name, title, tokens)
      super
      @title = title
    end
    require "kramdown"

    def render(context)
      text = super

      "<div class='info-block'>
        <div class = 'info-box'>
          <div class='box-title'>
              #{@title}
          </div>
          <div class='box-contents'>
              <div>
                #{Kramdown::Document.new(text).to_html}
              </div>
          </div>
        </div>
      </div>"
    end

  end
end

Liquid::Template.register_tag('info_box', Jekyll::InfoBoxBlock)
