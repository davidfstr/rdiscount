rootdir = File.dirname(File.dirname(__FILE__))
$LOAD_PATH.unshift "#{rootdir}/lib"

require 'test/unit'
require 'markdown'

MARKDOWN_TEST_DIR = "#{rootdir}/test/MarkdownTest_1.0.3"

class MarkdownTest < Test::Unit::TestCase

  def test_that_extension_methods_are_present_on_markdown_class
      assert Markdown.instance_methods.map{|m| m.to_s }.include?('to_html'),
        "Markdown class should respond to #to_html"
  end

  def test_that_simple_one_liner_goes_to_html
    markdown = Markdown.new('Hello World.', :MKD_NOPANTS)
    assert_respond_to markdown, :to_html
    assert_equal "<p>Hello World.</p>", markdown.to_html.strip
  end

  def test_that_inline_markdown_goes_to_html
    markdown = Markdown.new('_Hello World_!', :MKD_NOPANTS)
    assert_equal "<p><em>Hello World</em>!</p>", markdown.to_html.strip
  end

  def test_that_inline_markdown_starts_and_ends_correctly
    markdown = Markdown.new('_start _ foo_bar bar_baz _ end_ *italic* **bold** <a>_blah_</a>', :MKD_NOPANTS)
    assert_respond_to markdown, :to_html
    assert_equal "<p><em>start _ foo_bar bar_baz _ end</em> <em>italic</em> <strong>bold</strong> <a><em>blah</em></a></p>", markdown.to_html.strip

    markdown = Markdown.new("Run 'rake radiant:extensions:rbac_base:migrate'", :MKD_NOPANTS)
    assert_equal "<p>Run 'rake radiant:extensions:rbac_base:migrate'</p>", markdown.to_html.strip
  end

  def test_that_filter_html_works
    markdown = Markdown.new('Through <em>NO</em> <script>DOUBLE NO</script>', :MKD_NOPANTS, :MKD_NOHTML)
    assert_equal "<p>Through &lt;em>NO&lt;/em> &lt;script>DOUBLE NO&lt;/script></p>", markdown.to_html.strip
  end

  def test_that_bluecloth_restrictions_are_supported
    markdown = Markdown.new('Hello World.', :MKD_NOPANTS)
    [:filter_styles].each do |restriction|
      assert_respond_to markdown, restriction
      assert_respond_to markdown, "#{restriction}="
    end
    assert_not_equal RDiscount::MKD_NOHTML, markdown.flags & RDiscount::MKD_NOHTML
    assert_not_equal true, markdown.filter_styles

    markdown = Markdown.new('Hello World.', :MKD_NOPANTS, :MKD_NOHTML, :filter_styles)
    assert_equal RDiscount::MKD_NOHTML, markdown.flags & RDiscount::MKD_NOHTML
    assert_equal true, markdown.filter_styles
  end

  def test_that_redcloth_attributes_are_supported
    markdown = Markdown.new('Hello World.', :MKD_NOPANTS)
    assert_respond_to markdown, :fold_lines
    assert_respond_to markdown, :fold_lines=
    assert_not_equal true, markdown.fold_lines

    markdown = Markdown.new('Hello World.', :MKD_NOPANTS, :fold_lines)
    assert_equal true, markdown.fold_lines
  end

  def test_that_redcloth_to_html_with_single_arg_is_supported
    markdown = Markdown.new('Hello World.', :MKD_NOPANTS)
    assert_nothing_raised(ArgumentError) { markdown.to_html(true) }
  end

  def test_that_smart_converts_single_quotes_in_words_that_end_in_re
    markdown = Markdown.new("They're not for sale.")
    assert_equal "<p>They&rsquo;re not for sale.</p>\n", markdown.to_html
  end

  def test_that_smart_converts_single_quotes_in_words_that_end_in_ll
    markdown = Markdown.new("Well that'll be the day")
    assert_equal "<p>Well that&rsquo;ll be the day</p>\n", markdown.to_html
  end

  def test_that_urls_are_not_doubly_escaped
    markdown = Markdown.new('[Page 2](/search?query=Markdown+Test&page=2)', :MKD_NOPANTS)
    assert_equal "<p><a href=\"/search?query=Markdown+Test&amp;page=2\">Page 2</a></p>\n", markdown.to_html
  end

  def test_simple_inline_html
    markdown = Markdown.new("before\n\n<div>\n  foo\n</div>\nafter", :MKD_NOPANTS)
    assert_equal "<p>before</p>\n\n<div>\n  foo\n</div>\n\n\n<p>after</p>\n",
      markdown.to_html
  end

  def test_that_html_blocks_do_not_require_their_own_end_tag_line
    markdown = Markdown.new("Para 1\n\n<div><pre>HTML block\n</pre></div>\n\nPara 2 [Link](#anchor)", :MKD_NOPANTS)
    assert_equal "<p>Para 1</p>\n\n<div><pre>HTML block\n</pre></div>\n\n\n<p>Para 2 <a href=\"#anchor\">Link</a></p>\n",
      markdown.to_html
  end

  def test_filter_html_doesnt_break_two_space_hard_break
    markdown = Markdown.new("Lorem,  \nipsum\n", :MKD_NOPANTS, :MKD_NOHTML)
    assert_equal "<p>Lorem,<br/>\nipsum</p>\n",
      markdown.to_html
  end

  # This isn't in the spec but is Markdown.pl behavior.
  def test_block_quotes_preceded_by_spaces
    markdown = Markdown.new(
      "A wise man once said:\n\n" +
      " > Isn't it wonderful just to be alive.\n",
      :MKD_NOPANTS
    )
    assert_equal "<p>A wise man once said:</p>\n\n" +
      "<blockquote><p>Isn't it wonderful just to be alive.</p></blockquote>\n",
      markdown.to_html
  end

  def test_ul_with_zero_space_indent
    markdown = Markdown.new("- foo\n\n- bar\n\n  baz\n", :MKD_NOPANTS)
    assert_equal "<ul><li><p>foo</p></li><li><p>bar</p><p>baz</p></li></ul>",
      markdown.to_html.gsub("\n", "")
  end

  def test_ul_with_single_space_indent
    markdown = Markdown.new(" - foo\n\n - bar\n\n   baz\n", :MKD_NOPANTS)
    assert_equal "<ul><li><p>foo</p></li><li><p>bar</p><p>baz</p></li></ul>",
      markdown.to_html.gsub("\n", "")
  end

  # http://github.com/davidfstr/rdiscount/issues/#issue/13
  def test_headings_with_trailing_space
    text = "The Ant-Sugar Tales \n"         +
           "=================== \n\n"        +
           "By Candice Yellowflower   \n"
    markdown = Markdown.new(text, :MKD_NOPANTS)
    assert_equal "<h1>The Ant-Sugar Tales </h1>\n\n<p>By Candice Yellowflower</p>\n",
      markdown.to_html
  end

  # Build tests for each file in the MarkdownTest test suite

  Dir["#{MARKDOWN_TEST_DIR}/Tests/*.text"].each do |text_file|

    basename = File.basename(text_file).sub(/\.text$/, '')
    html_file = text_file.sub(/text$/, 'html')
    method_name = basename.gsub(/[-,()]/, '').gsub(/\s+/, '_').downcase

    define_method "test_#{method_name}" do
      markdown = Markdown.new(File.read(text_file), :MKD_NOPANTS)
      actual_html = markdown.to_html
      assert_not_nil actual_html
    end

    define_method "test_#{method_name}_smart" do
      markdown = Markdown.new(File.read(text_file))
      actual_html = markdown.to_html
      assert_not_nil actual_html
    end

  end

end
