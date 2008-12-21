$: << File.join(File.dirname(__FILE__), "../lib")

require 'test/unit'
require 'markdown'

MARKDOWN_TEST_DIR = "#{File.dirname(__FILE__)}/MarkdownTest_1.0.3"

class MarkdownTest < Test::Unit::TestCase

  def test_that_extension_methods_are_present_on_markdown_class
    assert Markdown.instance_methods.include?('to_html'),
      "Markdown class should respond to #to_html"
  end

  def test_that_simple_one_liner_goes_to_html
    markdown = Markdown.new('Hello World.')
    assert_respond_to markdown, :to_html
    assert_equal "<p>Hello World.</p>", markdown.to_html.strip
  end

  def test_that_inline_markdown_goes_to_html
    markdown = Markdown.new('_Hello World_!')
    assert_respond_to markdown, :to_html
    assert_equal "<p><em>Hello World</em>!</p>", markdown.to_html.strip
  end

  def test_that_inline_markdown_starts_and_ends_correctly
    markdown = Markdown.new('_start _ foo_bar bar_baz _ end_ *italic* **bold** <a>_blah_</a>')
    assert_respond_to markdown, :to_html
    assert_equal "<p><em>start _ foo_bar bar_baz _ end</em> <em>italic</em> <strong>bold</strong> <a><em>blah</em></a></p>", markdown.to_html.strip
  end

  def test_that_filter_html_works
    markdown = Markdown.new('Through <em>NO</em> <script>DOUBLE NO</script>', :filter_html)
    assert_equal "<p>Through &lt;em>NO&lt;/em> &lt;script>DOUBLE NO&lt;/script></p>", markdown.to_html.strip
  end

  def test_that_bluecloth_restrictions_are_supported
    markdown = Markdown.new('Hello World.')
    [:filter_html, :filter_styles].each do |restriction|
      assert_respond_to markdown, restriction
      assert_respond_to markdown, "#{restriction}="
    end
    assert_not_equal true, markdown.filter_html
    assert_not_equal true, markdown.filter_styles

    markdown = Markdown.new('Hello World.', :filter_html, :filter_styles)
    assert_equal true, markdown.filter_html
    assert_equal true, markdown.filter_styles
  end

  def test_that_redcloth_attributes_are_supported
    markdown = Markdown.new('Hello World.')
    assert_respond_to markdown, :fold_lines
    assert_respond_to markdown, :fold_lines=
    assert_not_equal true, markdown.fold_lines

    markdown = Markdown.new('Hello World.', :fold_lines)
    assert_equal true, markdown.fold_lines
  end

  def test_that_redcloth_to_html_with_single_arg_is_supported
    markdown = Markdown.new('Hello World.')
    assert_nothing_raised(ArgumentError) { markdown.to_html(true) }
  end

  def test_that_smart_converts_single_quotes_in_words_that_end_in_re
    markdown = Markdown.new("They're not for sale.", :smart)
    assert_equal "<p>They&rsquo;re not for sale.</p>\n", markdown.to_html
  end

  def test_that_smart_converts_single_quotes_in_words_that_end_in_ll
    markdown = Markdown.new("Well that'll be the day", :smart)
    assert_equal "<p>Well that&rsquo;ll be the day</p>\n", markdown.to_html
  end

  def test_that_urls_are_not_doubly_escaped
    markdown = Markdown.new('[Page 2](/search?query=Markdown+Test&page=2)')
    assert_equal "<p><a href=\"/search?query=Markdown+Test&amp;page=2\">Page 2</a></p>\n", markdown.to_html
  end

  # Build tests for each file in the MarkdownTest test suite

  Dir["#{MARKDOWN_TEST_DIR}/Tests/*.text"].each do |text_file|

    basename = File.basename(text_file).sub(/\.text$/, '')
    html_file = text_file.sub(/text$/, 'html')
    method_name = basename.gsub(/[-,]/, '').gsub(/\s+/, '_').downcase

    define_method "test_#{method_name}" do
      markdown = Markdown.new(File.read(text_file))
      actual_html = markdown.to_html
      assert_not_nil actual_html
    end

    define_method "test_#{method_name}_with_smarty_enabled" do
      markdown = Markdown.new(File.read(text_file), :smart)
      actual_html = markdown.to_html
      assert_not_nil actual_html
    end

  end

end
