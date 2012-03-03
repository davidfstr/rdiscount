Gem::Specification.new do |s|
  s.name = 'rdiscount'
  s.version = '1.6.8'
  s.summary = "Fast Implementation of Gruber's Markdown in C"
  s.date = '2011-01-25'
  s.email = 'rtomayko@gmail.com'
  s.homepage = 'http://github.com/rtomayko/rdiscount'
  s.authors = ["Ryan Tomayko", "David Loren Parsons", "Andrew White"]
  # = MANIFEST =
  s.files = %w[
    BUILDING
    COPYING
    README.markdown
    Rakefile
    bin/rdiscount
    discount
    lib/markdown.rb
    lib/rdiscount.rb
    lib/rdiscount-kramdown.rb
    man/markdown.7
    man/rdiscount.1
    man/rdiscount.1.ronn
    rdiscount-java.gemspec
    test/benchmark.rb
    test/benchmark.txt
    test/markdown_test.rb
    test/rdiscount_test.rb
  ]
  # = MANIFEST =
  s.test_files = ["test/markdown_test.rb", "test/rdiscount_test.rb"]
  s.extra_rdoc_files = ["COPYING"]
  s.executables = ["rdiscount"]
  s.require_paths = ["lib"]
  s.rubyforge_project = 'wink'
  s.add_dependency 'kramdown', '>= 0.13.5'
  s.platform = "java"
end
