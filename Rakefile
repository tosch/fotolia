require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/rdoctask'
require 'rake/testtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "fotolia"
    gemspec.summary = "Fotolia API Client"
    gemspec.description = "Provides a ruby interface to Fotolia via its XML-RPC api."
    gemspec.email = "torsten.schoenebaum@planquadrat-software.de"
    gemspec.homepage = "http://github.com/tosch/fotolia"
    gemspec.authors = ["Torsten Schönebaum"]
    gemspec.add_dependency('patron', '>= 0.4.4')
    gemspec.rdoc_options << '--line-numbers' << '--main' << 'README.rdoc'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::RDocTask.new do |rdoc|
  files =['README.rdoc', 'LICENSE', 'VERSION', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.rdoc" # page to start on
  rdoc.title = "Fotolia Client"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end
