require 'rdiscount'

class Moredown < RDiscount
  # Convert youtube videos to preview images (handy for valid RSS)
  attr_accessor :youtube_as_images
  
  # Don't use inline CSS for styling
  attr_accessor :has_stylesheet
  
  # Process emoticons
  attr_accessor :emotes
  
  # Map any relative URLs in the text to absolute URLs
  attr_accessor :base_url
  
  # Map headings down a few ranks (eg. :map_headings => 2 would convert h1 to h3)
  attr_accessor :map_headings
  
  # Create a Moredown Markdown processor. The +text+ argument
  # should be a string containing Markdown text. Additional arguments may be
  # supplied to set various processing options:
  #
  # * <tt>:extensions</tt> - Any of the following RDiscount Extensions:
  #   * <tt>:smart</tt> - Enable SmartyPants processing.
  #   * <tt>:filter_styles</tt> - Do not output <tt><style></tt> tags.
  #   * <tt>:filter_html</tt> - Do not output any raw HTML tags included in
  #     the source text.
  #   * <tt>:fold_lines</tt> - RedCloth compatible line folding (not used).
  # * <tt>:youtube_as_images</tt> - Convert youtube videos to preview images (handy for valid RSS).
  # * <tt>:has_stylesheet</tt> - Don't use inline CSS for styling.
  # * <tt>:emotes</tt> - Process emoticons.
  # * <tt>:base_url</tt> - Map any relative URLs in the text to absolute URLs.
  # * <tt>:map_headings</tt> - Map any headings down a few ranks (eg. h1 => h3).
  #
  # NOTE: The <tt>:filter_styles</tt> extension is not yet implemented.
  def initialize text, args = {}    
    @youtube_as_images = args[:youtube_as_images]
    @has_stylesheet = args[:has_stylesheet]
    @emotes = args[:emotes]
    @base_url = args[:base_url]
    @map_headings = args[:map_headings] || 0
    
    if args[:extensions]
      super(text, args[:extensions])
    else
      super(text)
    end
  end
  
  def to_html    
    html = super
    
    if @youtube_as_images
      html.gsub!(/<img src="youtube:(.*)?" alt="(.*)?" \/>/) { |match| "<img src=\"http://img.youtube.com/vi/#{$1}/default.jpg\" alt=\"#{$2}\" />" }
    else
      html.gsub!(/<img src="youtube:(.*)?" alt="(.*)?" \/>/) { |match| "<object data=\"http://www.youtube.com/v/#{$1}\" type=\"application/x-shockwave-flash\" width=\"425\" height=\"350\"><param name=\"movie\" value=\"http://www.youtube.com/v/#{$1}\" /></object>" }
    end
    
    # image alignments
    if @has_stylesheet
      html.gsub!(/<img (.*?) \/>:(left|right|center)/) { |match| "<img class=\"#{$2}\" #{$1} />" }
    else
      html.gsub!(/<img (.*?) \/>:left/) { |match| "<img style=\"float: left; margin: 0 10px 10px 0;\" #{$1} />" }
      html.gsub!(/<img (.*?) \/>:right/) { |match| "<img style=\"float: right; margin: 0 0 10px 10px;\" #{$1} />" }
      html.gsub!(/<img (.*?) \/>:center/) { |match| "<img style=\"display: block; margin: auto;\" #{$1} />" }
    end
    
    # code
    html.gsub!('<pre>', '<pre class="prettyprint">')
    
    # emoticons
    if @emotes
      html.gsub!(':-)', '<img src="/images/emote-smile.png" alt=":-)" width="16" height="16" />')
      html.gsub!(':-P', '<img src="/images/emote-tongue.png" alt=":-P" width="16" height="16" />')
      html.gsub!(':-D', '<img src="/images/emote-grin.png" alt=":-D" width="16" height="16" />')
      html.gsub!(':-(', '<img src="/images/emote-sad.png" alt=":-(" width="16" height="16" />')
      html.gsub!(':-@', '<img src="/images/emote-angry.png" alt=":-@" width="16" height="16" />')
      html.gsub!(';-)', '<img src="/images/emote-wink.png" alt=";-)" width="16" height="16" />')
    end
    
    # remap relative urls
    if @base_url
      html.gsub!('"/images/', "\"#{@base_url}/images/")
      html.gsub!('<a href="/', "<a href=\"#{@base_url}/")
    end
    
    # remap headings down a few notches
    if @map_headings > 0
      html.gsub!(/<(\/)?h(\d)>/) { |match| "<#{$1}h#{$2.to_i + @map_headings}>" }
    end
    
    html
  end
  
  # Process some text in Markdown format
  def self.text_to_html text, args = {}    
    Moredown.new(text, args).to_html
  end
end
