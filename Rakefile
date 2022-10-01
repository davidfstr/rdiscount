require 'date'
require 'rake/clean'
require 'digest/md5'

task :default => :test

# ==========================================================
# Ruby Extension
# ==========================================================

DLEXT = RbConfig::MAKEFILE_CONFIG['DLEXT']
RUBYDIGEST = Digest::MD5.hexdigest(`ruby --version`)

file "ext/ruby-#{RUBYDIGEST}" do |f|
  rm_f FileList["ext/ruby-*"]
  touch f.name
end
CLEAN.include "ext/ruby-*"

file 'ext/Makefile' => FileList['ext/*.{c,h,rb}', "ext/ruby-#{RUBYDIGEST}"] do
  chdir('ext') { ruby 'extconf.rb' }
end
CLEAN.include 'ext/Makefile', 'ext/mkmf.log'

file "ext/rdiscount.#{DLEXT}" => FileList["ext/Makefile"] do |f|
  sh 'cd ext && make clean && make && rm -rf conftest.dSYM'
end
CLEAN.include 'ext/*.{o,bundle,so,dll}'

file "lib/rdiscount.#{DLEXT}" => "ext/rdiscount.#{DLEXT}" do |f|
  cp f.prerequisites, "lib/", :preserve => true
end

desc 'Build the rdiscount extension'
task :build => "lib/rdiscount.#{DLEXT}"

# ==========================================================
# Manual
# ==========================================================

file 'man/rdiscount.1' => 'man/rdiscount.1.ronn' do
  sh "ronn --manual=RUBY -b man/rdiscount.1.ronn"
end
CLOBBER.include 'man/rdiscount.1'

desc 'Build manpages'
task :man => 'man/rdiscount.1'

# ==========================================================
# Testing
# ==========================================================

require 'rake/testtask'
Rake::TestTask.new('test:unit') do |t|
  t.test_files = FileList['test/*_test.rb']
  t.ruby_opts += ['-r rubygems'] if defined? Gem
end
task 'test:unit' => [:build]

desc 'Run conformance tests (MARKDOWN_TEST_VER=1.0)'
task 'test:conformance' => [:build] do |t|
  script = "#{pwd}/bin/rdiscount"
  test_version = ENV['MARKDOWN_TEST_VER'] || '1.0.3'
  lib_dir = "#{pwd}/lib"
  chdir("test/MarkdownTest_#{test_version}") do
    result = `RUBYLIB=#{lib_dir} ./MarkdownTest.pl --script='#{script}' --tidy`
    print result
    fail unless result.include? "; 0 failed."
  end

  # Allow to run this rake tasks multiple times
  # https://medium.com/@shaneilske/invoke-a-rake-task-multiple-times-1bcb01dee9d9
  ENV.delete("MARKDOWN_TEST_VER")
  ENV.delete("RDISCOUNT_EXTENSIONS")
  Rake::Task["test:conformance"].reenable
end

desc 'Run version 1.0 conformance suite'
task 'test:conformance:1.0' => [:build] do |t|
  ENV['MARKDOWN_TEST_VER'] = '1.0'
  # see https://github.com/Orc/discount/issues/261
  # requires flags -f1.0,tabstop,nopants
  ENV['RDISCOUNT_EXTENSIONS'] = "md1compat"
  Rake::Task['test:conformance'].invoke
end

desc 'Run 1.0.3 conformance suite'
task 'test:conformance:1.0.3' => [:build] do |t|
  ENV['MARKDOWN_TEST_VER'] = '1.0.3'
  Rake::Task['test:conformance'].invoke
end

desc 'Run unit and conformance tests'
task :test => %w[test:unit test:conformance:1.0 test:conformance:1.0.3]

desc 'Run benchmarks'
task :benchmark => :build do |t|
  $:.unshift 'lib'
  load 'test/benchmark.rb'
end

# ==========================================================
# Documentation
# ==========================================================

desc 'Generate API documentation'
task :doc => 'doc/index.html'

file 'doc/index.html' => FileList['lib/*.rb'] do |f|
  sh((<<-end).gsub(/\s+/, ' '))
    hanna --charset utf8 --fmt html --inline-source --line-numbers \
          --main RDiscount --op doc --title 'RDiscount API Documentation' \
          #{f.prerequisites.join(' ')}
  end
end

CLEAN.include 'doc'

# ==========================================================
# Update package's Discount sources
# ==========================================================

desc 'Gather required discount sources into extension directory'
task :gather => 'discount/markdown.h' do |t|
  # Files unique to /ext that should not be overridden
  rdiscount_ext_files = [
    "config.h",
    "extconf.rb",
    "rdiscount.c",
  ]
  
  # Files in /discount that have a main function and should not be copied to /ext
  discount_c_files_with_main_function = [
    "main.c",
    "makepage.c",
    "mkd2html.c",
    "theme.c",
  ]
  
  # Ensure configure.sh was run
  if not File.exists? 'discount/mkdio.h'
    abort "discount/mkdio.h not found. Did you run ./configure.sh in the discount directory?"
  end
  
  # Delete all *.c and *.h files from ext that are not specific to RDiscount.
  Dir.chdir("ext") do
    c_files_to_delete = Dir["*.c"].select { |e| !rdiscount_ext_files.include? e }
    h_files_to_delete = Dir["*.h"].select { |e| !rdiscount_ext_files.include? e }
    
    rm (c_files_to_delete + h_files_to_delete),
      :verbose => true
  end
  
  # Copy all *.c and *.h files from discount -> ext except those that
  # RDiscount overrides. Also exclude Discount files with main functions.
  Dir.chdir("discount") do
    c_files_to_copy = Dir["*.c"].select { |e|
      (!rdiscount_ext_files.include? e) &&
      (!discount_c_files_with_main_function.include? e)
    }
    h_files_to_copy = Dir["*.h"].select { |e| !rdiscount_ext_files.include? e }
  
    cp (c_files_to_copy + h_files_to_copy), '../ext/',
      :preserve => true,
      :verbose => true
  end
  
  # Copy special files from discount -> ext
  cp 'discount/blocktags', 'ext/'
  cp 'discount/VERSION', 'ext/'
  
  # Copy man page
  cp 'discount/markdown.7', 'man/'
end

file 'discount/markdown.h' do |t|
  abort "The discount submodule is required. See the file BUILDING for getting set up."
end

# PACKAGING =================================================================

require 'rubygems'
$spec = eval(File.read('rdiscount.gemspec'))

def package(ext='')
  "pkg/rdiscount-#{$spec.version}" + ext
end

desc 'Build packages'
task :package => %w[.gem .tar.gz].map {|e| package(e)}

desc 'Build and install as local gem'
task :install => package('.gem') do
  sh "gem install #{package('.gem')}"
end

directory 'pkg/'

file package('.gem') => %w[pkg/ rdiscount.gemspec] + $spec.files do |f|
  sh "gem build rdiscount.gemspec"
  mv File.basename(f.name), f.name
end

file package('.tar.gz') => %w[pkg/] + $spec.files do |f|
  sh "git archive --format=tar HEAD | gzip > #{f.name}"
end

# GEMSPEC HELPERS ==========================================================

def source_version
  line = File.read('lib/rdiscount.rb')[/^\s*VERSION = .*/]
  line.match(/.*VERSION = '(.*)'/)[1]
end

file 'rdiscount.gemspec' => FileList['Rakefile','lib/rdiscount.rb'] do |f|
  # read spec file and split out manifest section
  spec = File.read(f.name)
  head, manifest, tail = spec.split("  # = MANIFEST =\n")
  head.sub!(/\.version = '.*'/, ".version = '#{source_version}'")
  head.sub!(/\.date = '.*'/, ".date = '#{Date.today.to_s}'")
  # determine file list from git ls-files
  files = `git ls-files`.
    split("\n").
    sort.
    reject{ |file| file =~ /^\./ || file =~ /^test\/MarkdownTest/ }.
    map{ |file| "    #{file}" }.
    join("\n")
  # piece file back together and write...
  manifest = "  s.files = %w[\n#{files}\n  ]\n"
  spec = [head,manifest,tail].join("  # = MANIFEST =\n")
  File.open(f.name, 'w') { |io| io.write(spec) }
  puts "updated #{f.name}"
end
