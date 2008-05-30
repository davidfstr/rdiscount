$: << File.join(File.dirname(__FILE__), "lib")

require 'test/unit'
require 'discount'

class DiscountTest < Test::Unit::TestCase

  def test_that_extension_methods_are_present_on_discount_class
    assert Discount.instance_methods.include?('to_html'),
      "Discount class should respond to #to_html"
  end

  def test_converting_simple_string_to_html
    discount = Discount.new('Hello World.')
    assert_respond_to discount, :to_html
    assert_equal "<p>Hello World.</p>\n", discount.to_html
  end

  def test_converting_markup_string_to_html
    discount = Discount.new('_Hello World_!')
    assert_respond_to discount, :to_html
    assert_equal "<p><em>Hello World</em>!</p>\n", discount.to_html
  end

end
