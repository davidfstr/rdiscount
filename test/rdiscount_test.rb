$: << File.join(File.dirname(__FILE__), "../lib")

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
end
