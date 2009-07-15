require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'

spec = Gem::Specification.new do |s|
  s.name = %q{fotolia}
  s.version = '0.0.1'
  s.authors = ['Torsten Schönebaum']
  s.date = %q{2009-07-10}
  s.description = %q{Provides a ruby interface to Fotolia via its XML-RPC api}
  s.email = %q{torsten.schoenebaum@planquadrat-software.de}
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    '.gitignore',
     'LICENSE',
     'README',
     'Rakefile',
     'fotolia.gemspec',
     'lib/fotolia.rb',
     'lib/fotolia/base.rb',
     'lib/fotolia/categories.rb',
     'lib/fotolia/category.rb',
     'lib/fotolia/color.rb',
     'lib/fotolia/colors.rb',
     'lib/fotolia/conceptual_categories.rb',
     'lib/fotolia/conceptual_category.rb',
     'lib/fotolia/countries.rb',
     'lib/fotolia/country.rb',
     'lib/fotolia/galleries.rb',
     'lib/fotolia/gallery.rb',
     'lib/fotolia/language.rb',
     'lib/fotolia/medium.rb',
     'lib/fotolia/representative_categories.rb',
     'lib/fotolia/representative_category.rb',
     'lib/fotolia/search_result_set.rb',
     'lib/fotolia/tag.rb',
     'lib/fotolia/tags.rb',
     'lib/fotolia/user.rb'
  ]
  s.homepage = %q{http://www.planquadrat-software.de}
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Provides a ruby interface to Fotolia via its XML-RPC api}
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

Rake::RDocTask.new do |rdoc|
  files =['README', 'LICENSE', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README" # page to start on
  rdoc.title = "Fotolia Client"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end
