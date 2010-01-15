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

  def test_that_generate_toc_sets_toc_ids
    rd = RDiscount.new("# Level 1\n\n## Level 2", :generate_toc)
    assert rd.generate_toc
    assert_equal %(<h1 id="Level+1\">Level 1</h1>\n\n<h2 id="Level+2\">Level 2</h2>\n), rd.to_html
  end

  def test_should_get_the_generated_toc
    rd = RDiscount.new("# Level 1\n\n## Level 2", :generate_toc)
    exp = %(<ul>\n <li><a href="#Level+1">Level 1</a>\n  <ul>\n  <li><a href="#Level+2">Level 2</a>  </li>\n  </ul>\n </li>\n </ul>)
    assert_equal exp, rd.toc_content.strip
  end

  if "".respond_to?(:encoding)
    def test_should_return_string_in_same_encoding_as_input
      input = "Yogācāra"
      output = RDiscount.new(input).to_html
      puts output.encoding.name
      assert_equal input.encoding.name, output.encoding.name
    end
  end
end
