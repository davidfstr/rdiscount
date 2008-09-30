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
end
