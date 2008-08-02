# Discount is an implementation of John Gruber's Markdown markup
# language in C. It implements all of the language as described in
# {Markdown Syntax}[http://daringfireball.net/projects/markdown/syntax]
# and passes the Markdown 1.0 test suite. The RDiscount extension makes
# the Discount processor available via a Ruby C Extension library.
#
# === Usage
#
# RDiscount implements the basic protocol popularized by RedCloth and adopted
# by BlueCloth:
#   require 'rdiscount'
#   markdown = RDiscount.new("Hello World!")
#   puts markdown.to_html
#
# === Replacing BlueCloth
#
# Inject RDiscount into your BlueCloth-using code by replacing your bluecloth
# require statements with the following:
#   begin
#     require 'rdiscount'
#     BlueCloth = RDiscount
#   rescue LoadError
#     require 'bluecloth'
#   end
#
class RDiscount

  # Original Markdown formatted text.
  attr_reader :text

  # Set true to have smarty-like quote translation performed.
  attr_accessor :smart

  # BlueCloth compatible output filtering.
  attr_accessor :filter_styles, :filter_html

  # RedCloth compatible line folding -- not used for Markdown but
  # included for compatibility.
  attr_accessor :fold_lines

  # Create a RDiscount Markdown processor. The +text+ argument
  # should be a string containing Markdown text. Additional arguments may be
  # supplied to set various processing options:
  #
  # * <tt>:smart</tt> - Enable SmartyPants processing.
  # * <tt>:filter_styles</tt> - Do not output <tt><style></tt> tags.
  # * <tt>:filter_html</tt> - Do not output any raw HTML tags included in
  #   the source text.
  # * <tt>:fold_lines</tt> - RedCloth compatible line folding (not used).
  #
  # NOTE: The <tt>:filter_styles</tt> and <tt>:filter_html</tt> extensions
  # are not yet implemented.
  def initialize(text, *extensions)
    @text  = text
    @smart = nil
    @filter_styles = nil
    @filter_html = nil
    @fold_lines = nil
    extensions.each { |e| send("#{e}=", true) }
  end

end

Markdown = RDiscount unless defined? Markdown

require 'rdiscount.so'
