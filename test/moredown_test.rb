rootdir = File.dirname(File.dirname(__FILE__))
$LOAD_PATH.unshift "#{rootdir}/lib"

require 'test/unit'
require 'moredown'

class MoredownTest < Test::Unit::TestCase
  def test_that_base_markdown_is_working
    text = "Hello. This is **bold**."
    html = "<p>Hello. This is <strong>bold</strong>.</p>\n"
    assert_equal html, Moredown.text_to_html(text)
  end
  
  def test_moredown
    text = "Hello. This is **bold**."
    html = "<p>Hello. This is <strong>bold</strong>.</p>\n"
    assert_equal html, Moredown.new(text).to_html
  end
  
  
  def test_youtube_videos
    text = "![Video](youtube:12345678)"
    html = "<p><object id=\"swf-1\" classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" width=\"425\" height=\"350\"><param name=\"movie\" value=\"http://www.youtube.com/v/12345678\" /><!--[if !IE]>--><object type=\"application/x-shockwave-flash\" data=\"http://www.youtube.com/v/12345678\" width=\"425\" height=\"350\"><!--<![endif]--><a href=\"http://www.youtube.com/v/12345678\"><img src=\"http://img.youtube.com/vi/12345678/default.jpg\" alt=\"\" /></a><!--[if !IE]>--></object><!--<![endif]--></object></p>\n"
    assert_equal html, Moredown.text_to_html(text)
    
    text = <<TEXT
Here is a video:
    
![Video](youtube:12345678)
    
That was _awesome_.
TEXT
    html = "<p>Here is a video:</p>\n\n<p><object id=\"swf-1\" classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" width=\"425\" height=\"350\"><param name=\"movie\" value=\"http://www.youtube.com/v/12345678\" /><!--[if !IE]>--><object type=\"application/x-shockwave-flash\" data=\"http://www.youtube.com/v/12345678\" width=\"425\" height=\"350\"><!--<![endif]--><a href=\"http://www.youtube.com/v/12345678\"><img src=\"http://img.youtube.com/vi/12345678/default.jpg\" alt=\"\" /></a><!--[if !IE]>--></object><!--<![endif]--></object></p>\n\n<p>That was <em>awesome</em>.</p>\n"
    assert_equal html, Moredown.text_to_html(text)
  end
  
  def test_image_alignments
    text = "![Image](/image.jpg):left"
    html = "<p><img style=\"float: left; margin: 0 10px 10px 0;\" src=\"/image.jpg\" alt=\"Image\" /></p>\n"
    assert_equal html, Moredown.text_to_html(text)
    
    text = "![Image](/image.jpg):left"
    html = "<p><img class=\"left\" src=\"/image.jpg\" alt=\"Image\" /></p>\n"
    assert_equal html, Moredown.text_to_html(text, :has_stylesheet => true)
    
    text = "![Image](/image.jpg):right"
    html = "<p><img style=\"float: right; margin: 0 0 10px 10px;\" src=\"/image.jpg\" alt=\"Image\" /></p>\n"
    assert_equal html, Moredown.text_to_html(text)
    
    text = "![Image](/image.jpg):right"
    html = "<p><img class=\"right\" src=\"/image.jpg\" alt=\"Image\" /></p>\n"
    assert_equal html, Moredown.text_to_html(text, :has_stylesheet => true)
    
    text = "![Image](/image.jpg):center"
    html = "<p><img style=\"display: block; margin: auto;\" src=\"/image.jpg\" alt=\"Image\" /></p>\n"
    assert_equal html, Moredown.text_to_html(text)
    
    text = "![Image](/image.jpg):center"
    html = "<p><img class=\"center\" src=\"/image.jpg\" alt=\"Image\" /></p>\n"
    assert_equal html, Moredown.text_to_html(text, :has_stylesheet => true)
  end
  
  def test_code
    text = <<TEXT
Here is some code:

    def test_code
      puts 'test'
    end

That is all.
TEXT
    html = "<p>Here is some code:</p>\n\n<pre class=\"prettyprint\"><code>def test_code\n  puts 'test'\nend\n</code></pre>\n\n<p>That is all.</p>\n"
    assert_equal html, Moredown.text_to_html(text)
  end
  
  def test_emotes
    assert_equal "<p>:-)</p>\n", Moredown.text_to_html(':-)'), "Emotes are ignored when the switch is off"
    
    text = ':-)'
    html = "<p><img src=\"/images/emote-smile.png\" alt=\":-)\" width=\"16\" height=\"16\" /></p>\n"
    assert_equal html, Moredown.text_to_html(text, :emotes => true)
    
    text = ':-P'
    html = "<p><img src=\"/images/emote-tongue.png\" alt=\":-P\" width=\"16\" height=\"16\" /></p>\n"
    assert_equal html, Moredown.text_to_html(text, :emotes => true)
    
    text = ':-D'
    html = "<p><img src=\"/images/emote-grin.png\" alt=\":-D\" width=\"16\" height=\"16\" /></p>\n"
    assert_equal html, Moredown.text_to_html(text, :emotes => true)
    
    text = ':-('
    html = "<p><img src=\"/images/emote-sad.png\" alt=\":-(\" width=\"16\" height=\"16\" /></p>\n"
    assert_equal html, Moredown.text_to_html(text, :emotes => true)
    
    text = ':-@'
    html = "<p><img src=\"/images/emote-angry.png\" alt=\":-@\" width=\"16\" height=\"16\" /></p>\n"
    assert_equal html, Moredown.text_to_html(text, :emotes => true)
    
    text = ';-)'
    html = "<p><img src=\"/images/emote-wink.png\" alt=\";-)\" width=\"16\" height=\"16\" /></p>\n"
    assert_equal html, Moredown.text_to_html(text, :emotes => true)
  end
  
  def test_base_url
    text = "![Image](/images/test.jpg)"
    html = "<p><img src=\"http://www.example.com/images/test.jpg\" alt=\"Image\" /></p>\n"
    assert_equal html, Moredown.text_to_html(text, :base_url => 'http://www.example.com')
  end
  
  def test_remap_headings
    text = "<h1>Heading</h1>\n<h2>Sub-heading</h2>"
    html = "<h1>Heading</h1>\n\n\n<h2>Sub-heading</h2>\n\n"
    assert_equal html, Moredown.text_to_html(text, :map_headings => 0)
    
    text = "<h1>Heading</h1>\n<h2>Sub-heading</h2>"
    html = "<h2>Heading</h2>\n\n\n<h3>Sub-heading</h3>\n\n"
    assert_equal html, Moredown.text_to_html(text, :map_headings => 1)
    
    text = "<h1>Heading</h1>\n<h2>Sub-heading</h2>"
    html = "<h3>Heading</h3>\n\n\n<h4>Sub-heading</h4>\n\n"
    assert_equal html, Moredown.text_to_html(text, :map_headings => 2)
    
    text = <<TEXT
Heading
=======

Sub-heading
-----------
TEXT
    html = "<h3>Heading</h3>\n\n<h4>Sub-heading</h4>\n"
    assert_equal html, Moredown.text_to_html(text, :map_headings => 2)
  end
  
  def test_flash_movies
    text = '![Flash](flash:movieclip.swf)'
    html = "<p><object id=\"swf-1\" classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" width=\"400\" height=\"300\"><param name=\"movie\" value=\"movieclip.swf\" /><!--[if !IE]>--><object type=\"application/x-shockwave-flash\" data=\"movieclip.swf\" width=\"400\" height=\"300\"><!--<![endif]-->Flash is not available.<!--[if !IE]>--></object><!--<![endif]--></object></p>\n"
    assert_equal html, Moredown.text_to_html(text)
    
    text = '![Flash](flash:movieclip.swf "800 600")'
    html = "<p><object id=\"swf-1\" classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" width=\"800\" height=\"600\"><param name=\"movie\" value=\"movieclip.swf\" /><!--[if !IE]>--><object type=\"application/x-shockwave-flash\" data=\"movieclip.swf\" width=\"800\" height=\"600\"><!--<![endif]-->Flash is not available.<!--[if !IE]>--></object><!--<![endif]--></object></p>\n"
    assert_equal html, Moredown.text_to_html(text)
  end
  
  def test_swfobject
    text = "Here is some flash:

![Flash](flash:movieclip.swf)

![Flash](flash:movieclip.swf)

And that's all."
    html = "<script type=\"text/javascript\" src=\"./swfobject.js\"></script><script type=\"text/javascript\">
//<![CDATA[
swfobject.registerObject(\"swf-1\", \"10\");
swfobject.registerObject(\"swf-2\", \"10\");
//]]>
</script>
<p>Here is some flash:</p>

<p><object id=\"swf-1\" classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" width=\"400\" height=\"300\"><param name=\"movie\" value=\"movieclip.swf\" /><!--[if !IE]>--><object type=\"application/x-shockwave-flash\" data=\"movieclip.swf\" width=\"400\" height=\"300\"><!--<![endif]-->No Flash<!--[if !IE]>--></object><!--<![endif]--></object></p>

<p><object id=\"swf-2\" classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" width=\"400\" height=\"300\"><param name=\"movie\" value=\"movieclip.swf\" /><!--[if !IE]>--><object type=\"application/x-shockwave-flash\" data=\"movieclip.swf\" width=\"400\" height=\"300\"><!--<![endif]-->No Flash<!--[if !IE]>--></object><!--<![endif]--></object></p>

<p>And that's all.</p>\n"
    assert_equal html, Moredown.text_to_html(text, :swfobject => { :js_src => './swfobject.js', :version => '10', :fallback => 'No Flash' })  
  end
end