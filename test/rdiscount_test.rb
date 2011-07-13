# encoding: utf-8
rootdir = File.dirname(File.dirname(__FILE__))
$LOAD_PATH.unshift "#{rootdir}/lib"

require 'test/unit'
require 'rdiscount'

class RDiscountTest < Test::Unit::TestCase
  def test_that_discount_does_not_blow_up_with_weird_formatting_case
    text = (<<-TEXT).gsub(/^ {4}/, '').rstrip
    1. some text

    1.
    TEXT
    RDiscount.new(text, :MKD_NOPANTS).to_html
  end

  def test_that_smart_converts_double_quotes_to_curly_quotes
    rd = RDiscount.new(%("Quoted text"))
    assert_equal %(<p>&ldquo;Quoted text&rdquo;</p>\n), rd.to_html
  end

  def test_that_smart_converts_double_quotes_to_curly_quotes_before_a_heading
    rd = RDiscount.new(%("Quoted text"\n\n# Heading))
    assert_equal %(<p>&ldquo;Quoted text&rdquo;</p>\n\n<h1>Heading</h1>\n), rd.to_html
  end

  def test_that_smart_converts_double_quotes_to_curly_quotes_after_a_heading
    rd = RDiscount.new(%(# Heading\n\n"Quoted text"))
    assert_equal %(<h1>Heading</h1>\n\n<p>&ldquo;Quoted text&rdquo;</p>\n), rd.to_html
  end

  def test_that_smart_gives_ve_suffix_a_rsquo
    rd = RDiscount.new("I've been meaning to tell you ..")
    assert_equal "<p>I&rsquo;ve been meaning to tell you ..</p>\n", rd.to_html
  end

  def test_that_smart_gives_m_suffix_a_rsquo
    rd = RDiscount.new("I'm not kidding")
    assert_equal "<p>I&rsquo;m not kidding</p>\n", rd.to_html
  end

  def test_that_smart_gives_d_suffix_a_rsquo
    rd = RDiscount.new("what'd you say?")
    assert_equal "<p>what&rsquo;d you say?</p>\n", rd.to_html
  end

  def test_that_generate_toc_sets_toc_ids
    rd = RDiscount.new("# Level 1\n\n## Level 2", :MKD_NOPANTS, :MKD_TOC)
    assert_equal RDiscount::MKD_TOC, rd.flags & RDiscount::MKD_TOC
    assert_equal %(<a name="Level.1"></a>\n<h1>Level 1</h1>\n\n<a name="Level.2"></a>\n<h2>Level 2</h2>\n), rd.to_html
  end

  def test_should_get_the_generated_toc
    rd = RDiscount.new("# Level 1\n\n## Level 2", :MKD_NOPANTS, :MKD_TOC)
    exp = %(<ul>\n <li><a href="#Level.1">Level 1</a></li>\n <li><ul>\n  <li><a href="#Level.2">Level 2</a></li>\n </ul></li>\n</ul>)
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
    rd = RDiscount.new(%(![dust mite](http://dust.mite/image.png) <img src="image.png" />), :MKD_NOPANTS, :MKD_NOIMAGE)
    assert rd.to_html !~ /<img/
  end

  def test_that_no_links_flag_works
    rd = RDiscount.new(%([This link](http://example.net/) <a href="links.html">links</a>), :MKD_NOPANTS, :MKD_NOLINKS)
    assert rd.to_html !~ /<a /
  end

  def test_that_no_tables_flag_works
    rd = RDiscount.new(<<EOS, :MKD_NOPANTS, :MKD_NOTABLES)
 aaa | bbbb
-----|------
hello|sailor
EOS
    assert rd.to_html !~ /<table/
  end

  def test_that_strict_flag_works
    rd = RDiscount.new("foo_bar_baz", :MKD_NOPANTS, :MKD_STRICT)
    assert_equal "<p>foo<em>bar</em>baz</p>\n", rd.to_html
  end

  def test_that_autolink_flag_works
    rd = RDiscount.new("http://github.com/rtomayko/rdiscount", :MKD_NOPANTS, :MKD_AUTOLINK)
    assert_equal "<p><a href=\"http://github.com/rtomayko/rdiscount\">http://github.com/rtomayko/rdiscount</a></p>\n", rd.to_html
  end

  def test_that_safelink_flag_works
    rd = RDiscount.new("[IRC](irc://chat.freenode.org/#freenode)", :MKD_NOPANTS, :MKD_SAFELINK)
    assert_equal "<p>[IRC](irc://chat.freenode.org/#freenode)</p>\n", rd.to_html
  end

  def test_that_no_pseudo_protocols_flag_works
    rd = RDiscount.new("[foo](id:bar)", :MKD_NOPANTS, :MKD_NO_EXT)
    assert_equal "<p>[foo](id:bar)</p>\n", rd.to_html
  end

  def test_that_tags_can_have_dashes_and_underscores
    rd = RDiscount.new("foo <asdf-qwerty>bar</asdf-qwerty> and <a_b>baz</a_b>", :MKD_NOPANTS)
    assert_equal "<p>foo <asdf-qwerty>bar</asdf-qwerty> and <a_b>baz</a_b></p>\n", rd.to_html
  end
end
