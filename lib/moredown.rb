require 'rdiscount'

class Moredown < RDiscount
  VERSION = '1.0.4'
  
  # Don't use inline CSS for styling
  attr_accessor :has_stylesheet
  
  # Process emoticons
  attr_accessor :emotes
  
  # Map any relative URLs in the text to absolute URLs
  attr_accessor :base_url
  
  # Map headings down a few ranks (eg. :map_headings => 2 would convert h1 to h3)
  attr_accessor :map_headings
  
  # Use SwfObject2 if available (eg. :swfobject => { :src => 'swfobject.js', :version => '10', :fallback => 'No Flash' })
  attr_accessor :swfobject
  
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
  # * <tt>:has_stylesheet</tt> - Don't use inline CSS for styling.
  # * <tt>:emotes</tt> - Process emoticons.
  # * <tt>:base_url</tt> - Map any relative URLs in the text to absolute URLs.
  # * <tt>:map_headings</tt> - Map any headings down a few ranks (eg. h1 => h3).
  # * <tt>:swfobject</tt> - Use SwfObject2 if available (eg. :swfobject => { :src => 'swfobject.js', :version => '10', :fallback => 'No Flash' })
  #
  # NOTE: The <tt>:filter_styles</tt> extension is not yet implemented.
  def initialize text, args = {}    
    @has_stylesheet = args[:has_stylesheet]
    @emotes = args[:emotes]
    @base_url = args[:base_url]
    @map_headings = args[:map_headings] || 0
    @swfobject = args[:swfobject]
    
    # each swfobject needs a unique id
    @next_flash_id = 0
    
    if args[:extensions]
      super(text, args[:extensions])
    else
      super(text)
    end
  end
  
  def to_html    
    html = super
    
    # flash movies (including youtube)
    html.gsub!(/<img src="(flash|youtube):(.*?)"\s?(?:title="(.*?)")? alt="(.*)" \/>/) do |match|
      # grab width and height
      if $3
        sizes = $3.split(' ')
        sizes = { :width => sizes[0], :height => sizes[1] }
      else
        sizes = {}
      end
      
      # check the source
      if $1.downcase == "youtube"
        url = "http://www.youtube.com/v/#{$2}"
        sizes = { :width => 425, :height => 350 }.merge sizes
      else
        url = $2
      end
      
      flash_tag url, sizes
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
      html.gsub!(/<img src="(.*?)"/) do |match|
        if $1.include? '://'
          url = $1
        else
          url = "#{@base_url.chomp('/')}/#{$1}"
        end
        "<img src=\"#{url}\""
      end
      html.gsub!('<a href="/', "<a href=\"#{@base_url}/")
    end
    
    # remap headings down a few notches
    if @map_headings > 0
      html.gsub!(/<(\/)?h(\d)>/) { |match| "<#{$1}h#{$2.to_i + @map_headings}>" }
    end
    
    # add the js for swfobject
    if @swfobject
      swfobjects = []
      1.upto(@next_flash_id).each do |n|
        swfobjects << "swfobject.registerObject(\"swf-#{n}\", \"#{@swfobject[:version]}\");\n"
      end
      
      # html seems to need to go after the swfobject javascript
      html = "<script type=\"text/javascript\" src=\"#{@swfobject[:src]}\"></script><script type=\"text/javascript\">\n/*<![CDATA[*/\n#{swfobjects}/*]]>*/\n</script>\n#{html}"
    end
    
    html
  end
  
  # Process some text in Markdown format
  def self.text_to_html text, args = {}    
    Moredown.new(text, args).to_html
  end
  
  
  protected
    def flash_tag url, args = {}
      args = {:width => 400, :height => 300, :fallback => 'Flash is not available.'}.merge args
      
      if url.include? 'youtube.com'
        fallback = "<a href=\"#{url}\"><img src=\"http://img.youtube.com/vi/#{url.split('/').last}/default.jpg\" alt=\"\" /></a>"
      elsif @swfobject
        fallback = @swfobject[:fallback]
      else
        fallback = args[:fallback]
      end        
      
      return "<object id=\"swf-#{@next_flash_id += 1}\" classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" width=\"#{args[:width]}\" height=\"#{args[:height]}\">" \
        +"<param name=\"movie\" value=\"#{url}\" />" \
        +"<!--[if !IE]>-->" \
        +"<object type=\"application/x-shockwave-flash\" data=\"#{url}\" width=\"#{args[:width]}\" height=\"#{args[:height]}\">" \
          +"<!--<![endif]-->#{fallback}<!--[if !IE]>-->" \
        +"</object>" \
        +"<!--<![endif]-->" \
      +"</object>"
    end
end
