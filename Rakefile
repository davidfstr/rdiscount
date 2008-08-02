require 'rake/clean'
require 'rake/packagetask'
require 'rake/gempackagetask'

task :default => 'test:unit'

DLEXT = Config::CONFIG['DLEXT']
VERS = '1.2.6.2'

spec =
  Gem::Specification.new do |s|
    s.name              = "rdiscount"
    s.version           = VERS
    s.summary           = "Fast Implementation of Gruber's Markdown in C"
    s.files             = FileList['README','COPYING','Rakefile','test/**','{lib,ext}/**.rb','ext/*.{c,h}']
    s.bindir            = 'bin'
    s.require_path      = 'lib'
    s.has_rdoc          = true
    s.extra_rdoc_files  = ['README', 'COPYING']
    s.test_files        = FileList['test/*_test.rb']
    s.extensions        = ['ext/extconf.rb']

    s.author            = 'Ryan Tomayko'
    s.email             = 'r@tomayko.com'
    s.homepage          = 'http://github.com/rtomayko/rdiscount'
    s.rubyforge_project = 'wink'
  end

  Rake::GemPackageTask.new(spec) do |p|
    p.gem_spec = spec
    p.need_tar_gz = true
    p.need_tar = false
    p.need_zip = false
  end


# ==========================================================
# Ruby Extension
# ==========================================================

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
task :build => "lib/rdiscount.#{DLEXT}"


# ==========================================================
# Testing
# ==========================================================

desc 'Run unit tests'
task 'test:unit' => [:build] do |t|
  ruby 'test/markdown_test.rb'
end

desc 'Run conformance tests (MARKDOWN_TEST_VER=1.0)'
task 'test:conformance' => [:build] do |t|
  script = "#{pwd}/bin/rdiscount"
  test_version = ENV['MARKDOWN_TEST_VER'] || '1.0'
  chdir("test/MarkdownTest_#{test_version}") do
    sh "./MarkdownTest.pl --script='#{script}' --tidy"
  end
end

desc 'Run version 1.0 conformance suite'
task 'test:conformance:1.0' => 'test:conformance'

desc 'Run 1.0.3 conformance suite'
task 'test:conformance:1.0.3' => [:build] do |t|
  ENV['MARKDOWN_TEST_VER'] = '1.0.3'
  Rake::Task['test:conformance'].invoke
end

desc 'Run unit and conformance tests'
task :test => %w[test:unit test:conformance]

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
    hanna --charset utf8 \
          --fmt html \
          --inline-source \
          --line-numbers \
          --main RDiscount \
          --op doc \
          --title 'RDiscount API Documentation' \
          #{f.prerequisites.join(' ')}
  end
end

CLEAN.include 'doc'


# ==========================================================
# Rubyforge
# ==========================================================

PKGNAME = "pkg/rdiscount-#{VERS}"

desc 'Publish new release to rubyforge'
task :release => [ "#{PKGNAME}.gem", "#{PKGNAME}.tar.gz" ] do |t|
  sh <<-end
    rubyforge add_release wink rdiscount #{VERS} #{PKGNAME}.gem &&
    rubyforge add_file    wink rdiscount #{VERS} #{PKGNAME}.tar.gz
  end
end

desc 'Publish API docs to rubyforge'
task :publish => :doc do |t|
  sh 'scp -rp doc/. rubyforge.org:/var/www/gforge-projects/wink/rdiscount'
end

# ==========================================================
# Discount Submodule
# ==========================================================

namespace :submodule do
  desc 'Init the upstream submodule'
  task :init do |t|
    unless File.exist? 'discount/markdown.c'
      rm_rf 'discount'
      sh 'git submodule init discount'
      sh 'git submodule update discount'
    end
  end

  desc 'Update the discount submodule'
  task :update => :init do
    sh 'git submodule update discount' unless File.symlink?('discount')
  end

  file 'discount/markdown.c' do
    Rake::Task['submodule:init'].invoke
  end
  task :exist => 'discount/markdown.c'
end

desc 'Gather required discount sources into extension directory'
task :gather => 'submodule:exist' do |t|
  files =
    FileList[
      'discount/{markdown,mkdio,amalloc,cstring}.h',
      'discount/{markdown,docheader,dumptree,generate,mkdio,resource}.c'
    ]
  cp files, 'ext/',
    :preserve => true,
    :verbose => true
end

