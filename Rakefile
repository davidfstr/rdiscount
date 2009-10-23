require 'rake/clean'

task :default => :test


# ==========================================================
# Packaging
# ==========================================================

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "moredown"
    gemspec.summary = "Markdown plus more!"
    gemspec.description = "An extension to the RDiscount Markdown formatter"
    gemspec.email = "nathan@nathanhoad.net"
    gemspec.homepage = "http://nathanhoad.net/projects/moredown"
    gemspec.authors = ["Nathan Hoad", "Ryan Tomayko", "David Loren Parsons"]
    gemspec.files = `git ls-files`.split("\n").sort.reject{ |file| file =~ /^\./ || file =~ /^test\/MarkdownTest/ }
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end



# ==========================================================
# Ruby Extension
# ==========================================================

DLEXT = Config::CONFIG['DLEXT']

file 'ext/Makefile' => FileList['ext/{*.c,*.h,*.rb}'] do
  chdir('ext') { ruby 'extconf.rb' }
end
CLEAN.include 'ext/Makefile', 'ext/mkmf.log'

file "ext/rdiscount.#{DLEXT}" => FileList['ext/Makefile', 'ext/*.{c,h,rb}'] do |f|
  sh 'cd ext && make'
end
CLEAN.include 'ext/*.{o,bundle,so,dll}'

file "lib/rdiscount.#{DLEXT}" => "ext/rdiscount.#{DLEXT}" do |f|
  cp f.prerequisites, "lib/", :preserve => true
end

desc 'Build the rdiscount extension'
task :build_ext => "lib/rdiscount.#{DLEXT}"

# ==========================================================
# Testing
# ==========================================================

desc 'Run unit tests'
task 'test:unit' => [:build_ext] do |t|
  sh 'testrb test/moredown_test.rb test/markdown_test.rb test/rdiscount_test.rb'
end

desc 'Run conformance tests (MARKDOWN_TEST_VER=1.0)'
task 'test:conformance' => [:build_ext] do |t|
  script = "#{pwd}/bin/rdiscount"
  test_version = ENV['MARKDOWN_TEST_VER'] || '1.0.3'
  chdir("test/MarkdownTest_#{test_version}") do
    sh "./MarkdownTest.pl --script='#{script}' --tidy"
  end
end

desc 'Run version 1.0 conformance suite'
task 'test:conformance:1.0' => [:build_ext] do |t|
  ENV['MARKDOWN_TEST_VER'] = '1.0'
  Rake::Task['test:conformance'].invoke
end

desc 'Run 1.0.3 conformance suite'
task 'test:conformance:1.0.3' => [:build_ext] do |t|
  ENV['MARKDOWN_TEST_VER'] = '1.0.3'
  Rake::Task['test:conformance'].invoke
end

desc 'Run unit and conformance tests'
task :test => %w[test:unit test:conformance]

desc 'Run benchmarks'
task :benchmark => :build_ext do |t|
  $:.unshift 'lib'
  load 'test/benchmark.rb'
end

# ==========================================================
# Update package's Discount sources
# ==========================================================

desc 'Gather required discount sources into extension directory'
task :gather => 'discount' do |t|
  files =
    FileList[
      'discount/{markdown,mkdio,amalloc,cstring}.h',
      'discount/{markdown,docheader,dumptree,generate,mkdio,resource,toc,Csio}.c'
    ]
  cp files, 'ext/',
    :preserve => true,
    :verbose => true
end

# best. task. ever.
file 'discount' do |f|
  STDERR.puts((<<-TEXT).gsub(/^ +/, ''))
    Sorry, this operation requires a human. Tell your human to:

    Grab a discount tarball from:
    http://www.pell.portland.or.us/~orc/Code/discount/

    Extract here with something like:
    tar xvzf discount-1.2.9.tar.gz

    Create a discount symlink pointing at the version directory:
    ln -hsf discount-1.2.9 discount

  TEXT
  fail "discount sources required."
end
