require 'discount.so'

class Discount

  # Original Markdown formatted text.
  attr_reader :text

  # Set true to have smarty-like quote translation performed.
  attr_accessor :smart

  # BlueCloth compatible output filtering.
  attr_accessor :filter_styles, :filter_html

  # RedCloth compatible line folding -- not used for Markdown but
  # included for compatibility.
  attr_accessor :fold_lines

  def initialize(text, *extensions)
    @text  = text
    @smart = nil
    @filter_styles = nil
    @filter_html = nil
    @fold_lines = nil
    extensions.each { |e| send("#{e}=", true) }
  end

end
