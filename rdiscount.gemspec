Gem::Specification.new do |s|
  s.name = 'rdiscount'
  s.version = '2.2.7'
  s.summary = "Fast Implementation of Gruber's Markdown in C"
  s.email = 'david@dafoster.net'
  s.homepage = 'http://dafoster.net/projects/rdiscount/'
  s.authors = ["Ryan Tomayko", "David Loren Parsons", "Andrew White", "David Foster", "l33tname"]
  s.license = "BSD-3-Clause"
  # = MANIFEST =
  s.files = %w[
    BUILDING
    COPYING
    README.markdown
    Rakefile
    bin/rdiscount
    discount
    ext/amalloc.c
    ext/amalloc.h
    ext/basename.c
    ext/blocktags
    ext/config.h
    ext/Csio.c
    ext/css.c
    ext/cstring.h
    ext/docheader.c
    ext/dumptree.c
    ext/emmatch.c
    ext/extconf.rb
    ext/flags.c
    ext/generate.c
    ext/gethopt.c
    ext/gethopt.h
    ext/github_flavoured.c
    ext/h1title.c
    ext/html5.c
    ext/markdown.c
    ext/markdown.h
    ext/mkdio.c
    ext/mkdio.h
    ext/mktags.c
    ext/notspecial.c
    ext/pgm_options.c
    ext/pgm_options.h
    ext/rdiscount.c
    ext/resource.c
    ext/setup.c
    ext/tags.c
    ext/tags.h
    ext/toc.c
    ext/VERSION
    ext/version.c
    ext/xml.c
    ext/xmlpage.c
    lib/markdown.rb
    lib/rdiscount.rb
    man/markdown.7
    man/rdiscount.1
    man/rdiscount.1.ronn
    rdiscount.gemspec
    test/benchmark.rb
    test/benchmark.txt
    test/markdown_test.rb
    test/rdiscount_test.rb
  ]
  # = MANIFEST =
  s.test_files = ["test/markdown_test.rb", "test/rdiscount_test.rb"]
  s.extra_rdoc_files = ["COPYING"]
  s.extensions = ["ext/extconf.rb"]
  s.executables = ["rdiscount"]
  s.require_paths = ["lib"]
end
