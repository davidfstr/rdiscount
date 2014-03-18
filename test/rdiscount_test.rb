# encoding: utf-8
rootdir = File.dirname(File.dirname(__FILE__))
$LOAD_PATH.unshift "#{rootdir}/lib"

require 'test/unit'
require 'rdiscount'

class RDiscountTest < Test::Unit::TestCase
  def test_that_version_looks_valid
    if not /^[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?$/ =~ RDiscount::VERSION
      assert false, 'Expected RDiscount::VERSION to be a 3 or 4 component version string but found ' + RDiscount::VERSION.to_s
    end
  end
  
  def test_that_discount_does_not_blow_up_with_weird_formatting_case
    text = (<<-TEXT).gsub(/^ {4}/, '').rstrip
    1. some text

    1.
    TEXT
    RDiscount.new(text).to_html
  end

  def test_that_smart_converts_double_quotes_to_curly_quotes
    rd = RDiscount.new(%("Quoted text"), :smart)
    assert_equal %(<p>&ldquo;Quoted text&rdquo;</p>\n), rd.to_html
  end

  def test_that_smart_converts_double_quotes_to_curly_quotes_before_a_heading
    rd = RDiscount.new(%("Quoted text"\n\n# Heading), :smart)
    assert_equal %(<p>&ldquo;Quoted text&rdquo;</p>\n\n<h1>Heading</h1>\n), rd.to_html
  end

  def test_that_smart_converts_double_quotes_to_curly_quotes_after_a_heading
    rd = RDiscount.new(%(# Heading\n\n"Quoted text"), :smart)
    assert_equal %(<h1>Heading</h1>\n\n<p>&ldquo;Quoted text&rdquo;</p>\n), rd.to_html
  end

  def test_that_smart_gives_ve_suffix_a_rsquo
    rd = RDiscount.new("I've been meaning to tell you ..", :smart)
    assert_equal "<p>I&rsquo;ve been meaning to tell you ..</p>\n", rd.to_html
  end

  def test_that_smart_gives_m_suffix_a_rsquo
    rd = RDiscount.new("I'm not kidding", :smart)
    assert_equal "<p>I&rsquo;m not kidding</p>\n", rd.to_html
  end

  def test_that_smart_gives_d_suffix_a_rsquo
    rd = RDiscount.new("what'd you say?", :smart)
    assert_equal "<p>what&rsquo;d you say?</p>\n", rd.to_html
  end

  def test_that_generate_toc_sets_toc_ids
    rd = RDiscount.new("# Level 1\n\n## Level 2", :generate_toc)
    assert rd.generate_toc
    assert_equal %(<a name="Level.1"></a>\n<h1>Level 1</h1>\n\n<a name="Level.2"></a>\n<h2>Level 2</h2>\n), rd.to_html
  end

  def test_should_get_the_generated_toc
    rd = RDiscount.new("# Level 1\n\n## Level 2", :generate_toc)
    exp = %(<ul>\n <li><a href=\"#Level.1\">Level 1</a>\n <ul>\n  <li><a href=\"#Level.2\">Level 2</a></li>\n </ul>\n </li>\n</ul>)
    assert_equal exp, rd.toc_content.strip
  end
  
  def test_toc_should_escape_apostropes
    rd = RDiscount.new("# A'B\n\n## C", :generate_toc)
    exp = %(<ul>\n <li><a href=\"#A.B\">A'B</a>\n <ul>\n  <li><a href=\"#C\">C</a></li>\n </ul>\n </li>\n</ul>)
    assert_equal exp, rd.toc_content.strip
  end
  
  def test_toc_should_escape_question_marks
    rd = RDiscount.new("# A?B\n\n## C", :generate_toc)
    exp = %(<ul>\n <li><a href=\"#A.B\">A?B</a>\n <ul>\n  <li><a href=\"#C\">C</a></li>\n </ul>\n </li>\n</ul>)
    assert_equal exp, rd.toc_content.strip
  end

  if "".respond_to?(:encoding)
    def test_should_return_string_in_same_encoding_as_input
      input = "Yogācāra"
      output = RDiscount.new(input).to_html
      assert_equal input.encoding.name, output.encoding.name
    end
  end

  def test_that_no_image_flag_works
    rd = RDiscount.new(%(![dust mite](http://dust.mite/image.png) <img src="image.png" />), :no_image)
    assert rd.to_html !~ /<img/
  end

  def test_that_no_links_flag_works
    rd = RDiscount.new(%([This link](http://example.net/) <a href="links.html">links</a>), :no_links)
    assert rd.to_html !~ /<a /
  end

  def test_that_no_tables_flag_works
    rd = RDiscount.new(<<EOS, :no_tables)
 aaa | bbbb
-----|------
hello|sailor
EOS
    assert rd.to_html !~ /<table/
  end

  def test_that_strict_flag_works
    rd = RDiscount.new("foo_bar_baz", :strict)
    assert_equal "<p>foo<em>bar</em>baz</p>\n", rd.to_html
  end

  def test_that_autolink_flag_works
    rd = RDiscount.new("http://github.com/davidfstr/rdiscount", :autolink)
    assert_equal "<p><a href=\"http://github.com/davidfstr/rdiscount\">http://github.com/davidfstr/rdiscount</a></p>\n", rd.to_html
  end

  def test_that_safelink_flag_works
    rd = RDiscount.new("[IRC](irc://chat.freenode.org/#freenode)", :safelink)
    assert_equal "<p>[IRC](irc://chat.freenode.org/#freenode)</p>\n", rd.to_html
  end

  def test_that_no_pseudo_protocols_flag_works
    rd = RDiscount.new("[foo](id:bar)", :no_pseudo_protocols)
    assert_equal "<p>[foo](id:bar)</p>\n", rd.to_html
  end
  
  def test_that_no_superscript_flag_works
    rd = RDiscount.new("A^B", :no_superscript)
    assert_equal "<p>A^B</p>\n", rd.to_html
    
    rd = RDiscount.new("A^B")
    assert_equal "<p>A<sup>B</sup></p>\n", rd.to_html
  end
  
  def test_that_no_strikethrough_flag_works
    rd = RDiscount.new("~~A~~", :no_strikethrough)
    assert_equal "<p>~~A~~</p>\n", rd.to_html
    
    rd = RDiscount.new("~~A~~")
    assert_equal "<p><del>A</del></p>\n", rd.to_html
  end

  def test_that_tags_can_have_dashes_and_underscores
    if RDiscount::VERSION.start_with? "2.0.7"
      # Skip test for 2.0.7.x series due to upstream behavioral change in
      # Discount 2.0.7. This test can be fixed in Discount 2.1.5 using the
      # WITH_GITHUB_TAGS compile-time flag.
      return
    end
    rd = RDiscount.new("foo <asdf-qwerty>bar</asdf-qwerty> and <a_b>baz</a_b>")
    assert_equal "<p>foo <asdf-qwerty>bar</asdf-qwerty> and <a_b>baz</a_b></p>\n", rd.to_html
  end

  def test_that_footnotes_flag_works
    rd = RDiscount.new(<<EOS, :footnotes)
Obtuse text.[^1]

[^1]: Clarification
EOS
    assert rd.to_html.include?('<a href="#fn:1" rel="footnote">1</a>')
  end
  
  def test_that_unicode_urls_encoded_correctly
    rd = RDiscount.new("[Test](http://example.com/ß)")
    assert_equal "<p><a href=\"http://example.com/%C3%9F\">Test</a></p>\n", rd.to_html
  end
  
  def test_that_dashes_encoded_correctly
    rd = RDiscount.new("A--B", :smart)
    assert_equal "<p>A&ndash;B</p>\n", rd.to_html
    
    rd = RDiscount.new("A---B", :smart)
    assert_equal "<p>A&mdash;B</p>\n", rd.to_html
  end
  
  def test_that_superscripts_can_be_escaped
    rd = RDiscount.new("A\\^B")
    assert_equal "<p>A^B</p>\n", rd.to_html
    
    rd = RDiscount.new("A^B")
    assert_equal "<p>A<sup>B</sup></p>\n", rd.to_html
  end
  
  def test_that_style_tag_is_not_filtered_by_default
    rd = RDiscount.new("Hello<style>p { margin: 5px; }</style>")
    assert_equal "<p>Hello<style>p { margin: 5px; }</style></p>\n", rd.to_html
  end
  
  def test_that_tables_can_have_leading_and_trailing_pipes
    rd = RDiscount.new(<<EOS)
| A | B |
|---|---|
| C | D |
EOS
    assert_equal "<table>\n<thead>\n<tr>\n<th> A </th>\n<th> B </th>\n</tr>\n</thead>\n<tbody>\n<tr>\n<td> C </td>\n<td> D </td>\n</tr>\n</tbody>\n</table>\n\n", rd.to_html
  end
  
  def test_that_gfm_code_blocks_work
    rd = RDiscount.new(<<EOS)
```
line 1

line 2
```
EOS
    assert_equal "<pre><code>line 1\n\nline 2\n</code></pre>\n", rd.to_html
  end
  
  def test_that_gfm_code_blocks_work_with_language
    rd = RDiscount.new(<<EOS)
```ruby
line 1

line 2
```
EOS
    assert_equal "<pre><code class=\"ruby\">line 1\n\nline 2\n</code></pre>\n", rd.to_html
  end
  
  def test_that_pandoc_code_blocks_work
    rd = RDiscount.new(<<EOS)
~~~
line 1

line 2
~~~
EOS
    assert_equal "<pre><code>line 1\n\nline 2\n</code></pre>\n", rd.to_html
  end
  
  def test_that_discount_definition_lists_work
    rd = RDiscount.new(<<EOS)
=tag1=
=tag2=
    data.
EOS
    assert_equal <<EOS, rd.to_html
<dl>
<dt>tag1</dt>
<dt>tag2</dt>
<dd>data.</dd>
</dl>
EOS
  end
  
  def test_that_extra_definition_lists_work
    rd = RDiscount.new(<<EOS)
tag1
: data
EOS
    assert_equal <<EOS, rd.to_html
<dl>
<dt>tag1</dt>
<dd>data</dd>
</dl>
EOS
  end
  
  def test_that_emphasis_beside_international_characters_detected
    rd = RDiscount.new(%(*foo ä bar*))
    assert_equal %(<p><em>foo ä bar</em></p>\n), rd.to_html
    
    rd = RDiscount.new(%(*ä foobar*))
    assert_equal %(<p><em>ä foobar</em></p>\n), rd.to_html
    
    rd = RDiscount.new(%(*foobar ä*))
    assert_equal %(<p><em>foobar ä</em></p>\n), rd.to_html
  end
end
