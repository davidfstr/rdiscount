Gem::Specification.new do |s|
  s.name = 'moredown'
  s.version = '1.0.0'
  s.summary = "Fast Implementation of Gruber's Markdown in C"
  s.date = '2009-08-22'
  s.email = 'nathan@nathanhoad.net'
  s.homepage = 'http://github.com/nathanhoad/moredown'
  s.has_rdoc = true
  s.authors = ["Nathan Hoad", "Ryan Tomayko", "Andrew White"]
  # = MANIFEST =
  s.files = %w[
    COPYING
    README.markdown
    Rakefile
    bin/rdiscount
    ext/Csio.c
    ext/amalloc.h
    ext/config.h
    ext/cstring.h
    ext/docheader.c
    ext/dumptree.c
    ext/extconf.rb
    ext/generate.c
    ext/markdown.c
    ext/markdown.h
    ext/mkdio.c
    ext/mkdio.h
    ext/rdiscount.c
    ext/resource.c
    ext/toc.c
    lib/moredown.rb
    lib/markdown.rb
    lib/rdiscount.rb
    rdiscount.gemspec
    test/benchmark.rb
    test/benchmark.txt
    test/moredown_test.rb
    test/markdown_test.rb
    test/rdiscount_test.rb
  ]
  # = MANIFEST =
  s.test_files = ["test/moredown_test.rb", "test/markdown_test.rb", "test/rdiscount_test.rb"]
  s.extra_rdoc_files = ["COPYING"]
  s.extensions = ["ext/extconf.rb"]
  s.executables = ["rdiscount"]
  s.require_paths = ["lib"]
end
