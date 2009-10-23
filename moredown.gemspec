# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{moredown}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nathan Hoad", "Ryan Tomayko", "David Loren Parsons"]
  s.date = %q{2009-10-23}
  s.default_executable = %q{rdiscount}
  s.description = %q{An extension to the RDiscount Markdown formatter}
  s.email = %q{nathan@nathanhoad.net}
  s.executables = ["rdiscount"]
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "COPYING",
     "README.markdown",
     "Rakefile",
     "VERSION",
     "bin/rdiscount",
     "ext/Csio.c",
     "ext/amalloc.h",
     "ext/config.h",
     "ext/cstring.h",
     "ext/docheader.c",
     "ext/dumptree.c",
     "ext/extconf.rb",
     "ext/generate.c",
     "ext/markdown.c",
     "ext/markdown.h",
     "ext/mkdio.c",
     "ext/mkdio.h",
     "ext/rdiscount.c",
     "ext/resource.c",
     "ext/toc.c",
     "lib/markdown.rb",
     "lib/moredown.rb",
     "lib/rdiscount.rb",
     "moredown.gemspec",
     "test/benchmark.rb",
     "test/benchmark.txt",
     "test/markdown_test.rb",
     "test/moredown_test.rb",
     "test/rdiscount_test.rb"
  ]
  s.homepage = %q{http://nathanhoad.net/projects/moredown}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Markdown plus more!}
  s.test_files = [
    "test/benchmark.rb",
     "test/markdown_test.rb",
     "test/moredown_test.rb",
     "test/rdiscount_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

