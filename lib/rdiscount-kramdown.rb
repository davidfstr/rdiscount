require 'kramdown'

class RDiscount
  class ::Kramdown::Converter::Rdiscounthtml < Kramdown::Converter::Html
    def initialize(root, options)
      super
      self.indent = 0
    end
  end
  
  def to_html(*)
    text = self.text
    html = Kramdown::Document.new(text).to_rdiscounthtml
    if text.respond_to? :encoding
      html.force_encoding text.encoding
    end
    html
  end
  
  def toc_content(*)
    text = self.text
    html = Kramdown::Document.new(text).to_toc
    if text.respond_to? :encoding
      html.force_encoding text.encoding
    end
    html
  end
end