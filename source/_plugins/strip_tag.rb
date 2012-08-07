module Jekyll
  class StripTag < Liquid::Block
    @total_economy = 0
    class << self
      attr_accessor :total_economy
    end

    begin
      require 'html_press'
      def render(context)
        text = super
        before = text.bytesize
        text = HtmlPress.press text
        after = text.bytesize

        self.class.total_economy += before - after
        economy = (self.class.total_economy.to_f / 1024).round(2)
        p 'totally saved: ' + economy.to_s + ' Kb'
        text
      end
    rescue LoadError => e
      p "Unable to load 'html_press'"
    end
  end
end

Liquid::Template.register_tag('strip', Jekyll::StripTag)