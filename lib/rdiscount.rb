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
  VERSION = '1.6.8'

  # Original Markdown formatted text.
  attr_reader :text

  # Integer containing bit flags for the underlying Discount library.
  attr_accessor :flags

  # Do not output <tt><style></tt> tags included in the source text.
  attr_accessor :filter_styles

  # RedCloth compatible line folding -- not used for Markdown but
  # included for compatibility.
  attr_accessor :fold_lines

  # Create a RDiscount Markdown processor. The +text+ argument should be a
  # string containing Markdown text. Additional arguments may be supplied to
  # set various processing options:
  #
  # * <tt>:filter_styles</tt>       - Do not output <tt><style></tt> tags.
  # * <tt>:fold_lines</tt>          - RedCloth compatible line folding (not used).
  # * <tt>:MKD_NOLINKS</tt>         - Don't do link processing, block <a> tags
  # * <tt>:MKD_NOIMAGE</tt>         - Don't do image processing, block <img>
  # * <tt>:MKD_NOPANTS</tt>         - Don't run smartypants()
  # * <tt>:MKD_NOHTML</tt>          - Don't allow raw html through AT ALL
  # * <tt>:MKD_STRICT</tt>          - Disable SUPERSCRIPT, RELAXED_EMPHASIS
  # * <tt>:MKD_TAGTEXT</tt>         - Process text inside an html tag; no <em>, no <bold>, no html or [] expansion
  # * <tt>:MKD_NO_EXT</tt>          - Don't allow pseudo-protocols
  # * <tt>:MKD_CDATA</tt>           - Generate code for xml ![CDATA[...]]
  # * <tt>:MKD_NOSUPERSCRIPT</tt>   - No A^B
  # * <tt>:MKD_NORELAXED</tt>       - Emphasis happens everywhere
  # * <tt>:MKD_NOTABLES</tt>        - Don't process PHP Markdown Extra tables.
  # * <tt>:MKD_NOSTRIKETHROUGH</tt> - Forbid ~~strikethrough~~
  # * <tt>:MKD_TOC</tt>             - Do table-of-contents processing
  # * <tt>:MKD_1_COMPAT</tt>        - Compatability with MarkdownTest_1.0
  # * <tt>:MKD_AUTOLINK</tt>        - Make http://foo.com a link even without <>s
  # * <tt>:MKD_SAFELINK</tt>        - Paranoid check for link protocol
  # * <tt>:MKD_NOHEADER</tt>        - Don't process document headers
  # * <tt>:MKD_TABSTOP</tt>         - Expand tabs to 4 spaces
  # * <tt>:MKD_NODIVQUOTE</tt>      - Forbid >%class% blocks
  # * <tt>:MKD_NOALPHALIST</tt>     - Forbid alphabetic lists
  # * <tt>:MKD_NODLIST</tt>         - Forbid definition lists
  #
  def initialize(text, *extensions)
    @text  = text
    @flags = 0
    extensions.each do |ext|
      writer = "#{ext}="
      if respond_to? writer
        send writer, true
      else
        @flags |= RDiscount.const_get(ext)
      end
    end
  end

end

Markdown = RDiscount unless defined? Markdown

require 'rdiscount.so'
