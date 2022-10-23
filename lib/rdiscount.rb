# Discount is an implementation of John Gruber's Markdown markup
# language in C. It implements all of the language as described in
# {Markdown Syntax}[http://daringfireball.net/projects/markdown/syntax]
# and passes the Markdown 1.0 test suite. The RDiscount extension makes
# the Discount processor available via a Ruby C Extension library.
#
# == Usage
#
# RDiscount implements the basic protocol popularized by RedCloth and adopted
# by BlueCloth:
#   require 'rdiscount'
#   markdown = RDiscount.new("Hello World!")
#   puts markdown.to_html
#
# == Replacing BlueCloth
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
  VERSION = '2.2.7'

  # Original Markdown formatted text.
  attr_reader :text

  # Set true to have smarty-like quote translation performed.
  attr_accessor :smart

  # Do not output <tt><style></tt> tags included in the source text.
  attr_accessor :filter_styles

  # Do not output any raw HTML included in the source text.
  attr_accessor :filter_html

  # RedCloth compatible line folding -- not used for Markdown but
  # included for compatibility.
  attr_accessor :fold_lines

  # Enable php markdown extra-style footnotes
  attr_accessor :footnotes

  # Enable Table Of Contents generation
  attr_accessor :generate_toc

  # Do not process <tt>![]</tt> and remove <tt><img></tt> tags from the output.
  attr_accessor :no_image

  # Do not process <tt>[]</tt> and remove <tt><a></tt> tags from the output.
  attr_accessor :no_links

  # Do not process tables
  attr_accessor :no_tables

  # Disable superscript and relaxed emphasis processing.
  attr_accessor :strict

  # Convert URL in links, even if they aren't encased in <tt><></tt>
  attr_accessor :autolink

  # Don't make hyperlinks from <tt>[][]</tt> links that have unknown URL types.
  attr_accessor :safelink

  # Do not process pseudo-protocols like <tt>[](id:name)</tt>
  attr_accessor :no_pseudo_protocols
  
  # Disable superscript processing.
  attr_accessor :no_superscript
  
  # Disable strikethrough processing.
  attr_accessor :no_strikethrough

  # Keep LaTeX inside $$ intact.
  attr_accessor :latex

  # Don't merge adjacent list into a single list.
  attr_accessor :explicitlist

  # Not documented: run in markdown 1 compat mode (only used for MarkdownTest1.0)
  attr_accessor :md1compat

  # Create a RDiscount Markdown processor. The +text+ argument
  # should be a string containing Markdown text. Additional arguments may be
  # supplied to set various processing options:
  #
  # * <tt>:smart</tt> - Enable SmartyPants processing.
  # * <tt>:filter_styles</tt> - Do not output <tt><style></tt> tags.
  # * <tt>:filter_html</tt> - Do not output any raw HTML tags included in
  #   the source text.
  # * <tt>:fold_lines</tt> - RedCloth compatible line folding (not used).
  # * <tt>:footnotes</tt> - PHP markdown extra-style footnotes.
  # * <tt>:generate_toc</tt> - Enable Table Of Contents generation
  # * <tt>:no_image</tt> - Do not output any <tt><img></tt> tags.
  # * <tt>:no_links</tt> - Do not output any <tt><a></tt> tags.
  # * <tt>:no_tables</tt> - Do not output any tables.
  # * <tt>:strict</tt> - Disable superscript and relaxed emphasis processing.
  # * <tt>:autolink</tt> - Greedily urlify links.
  # * <tt>:safelink</tt> - Do not make links for unknown URL types.
  # * <tt>:no_pseudo_protocols</tt> - Do not process pseudo-protocols.
  # * <tt>:no_superscript</tt> - Disable superscript processing.
  # * <tt>:no_strikethrough</tt> - Disable strikethrough processing.
  # * <tt>:latex</tt> - Keep LaTeX inside $$ intact.
  # * <tt>:explicitlist</tt> - Don't merge adjacent list into a single list.
  #
  def initialize(text, *extensions)
    @text  = text
    extensions.each { |e| send("#{e}=", true) }
  end

end

Markdown = RDiscount unless defined? Markdown

require 'rdiscount.so'
