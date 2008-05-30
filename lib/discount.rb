require 'discount.so'

class Discount

  # Original Markdown formatted text.
  attr_reader :text

  # Whether smarty-like quote translation should be performed.
  attr_accessor :smart

  # Whether footnotes should be 
  attr_accessor :notes

  def initialize(text, *extensions)
    @smart = false
    @notes = false
    @text  = text
    extensions.each { |e| send("#{e}=", true) }
  end

end
