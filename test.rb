$: << File.join(File.dirname(__FILE__), "lib")

require 'test/unit'
require 'discount'

class DiscountTest < Test::Unit::TestCase

  def test_that_extension_methods_are_present_on_discount_class
    assert Discount.instance_methods.include?('to_html'),
      "Discount class should respond to #to_html"
  end

  def test_that_simple_one_liner_goes_to_html
    discount = Discount.new('Hello World.')
    assert_respond_to discount, :to_html
    assert_equal "<p>Hello World.</p>\n", discount.to_html
  end

  def test_that_inline_markdown_goes_to_html
    discount = Discount.new('_Hello World_!')
    assert_respond_to discount, :to_html
    assert_equal "<p><em>Hello World</em>!</p>\n", discount.to_html
  end

  def test_that_bluecloth_restrictions_are_supported
    discount = Discount.new('Hello World.')
    [:filter_html, :filter_styles].each do |restriction|
      assert_respond_to discount, restriction
      assert_respond_to discount, "#{restriction}="
    end
    assert_not_equal true, discount.filter_html
    assert_not_equal true, discount.filter_styles

    discount = Discount.new('Hello World.', :filter_html, :filter_styles)
    assert_equal true, discount.filter_html
    assert_equal true, discount.filter_styles
  end

  def test_that_redcloth_attributes_are_supported
    discount = Discount.new('Hello World.')
    assert_respond_to discount, :fold_lines
    assert_respond_to discount, :fold_lines=
    assert_not_equal true, discount.fold_lines

    discount = Discount.new('Hello World.', :fold_lines)
    assert_equal true, discount.fold_lines
  end

  def test_that_redcloth_to_html_with_single_arg_is_supported
    discount = Discount.new('Hello World.')
    assert_nothing_raised(ArgumentError) { discount.to_html(true) }
  end

  # Build tests for each file in the MarkdownTest test suite

  Dir["#{File.dirname(__FILE__)}/test/MarkdownTest_1.0.3/Tests/*.text"].each do |text_file|

    basename = File.basename(text_file).sub(/\.text$/, '')
    html_file = text_file.sub(/text$/, 'html')
    method_name = basename.gsub(/[-,]/, '').gsub(/\s+/, '_').downcase

    define_method "test_#{method_name}" do
      discount = Discount.new(File.read(text_file))
      actual_html = discount.to_html
      assert_not_nil actual_html
    end

    define_method "test_#{method_name}_with_smarty_enabled" do
      discount = Discount.new(File.read(text_file), :smart)
      actual_html = discount.to_html
      assert_not_nil actual_html
    end

  end

end
