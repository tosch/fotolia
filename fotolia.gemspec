# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fotolia}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Torsten Sch\303\266nebaum"]
  s.date = %q{2009-09-03}
  s.description = %q{Provides a ruby interface to Fotolia via its XML-RPC api.}
  s.email = %q{torsten.schoenebaum@planquadrat-software.de}
  s.extra_rdoc_files = [
    "LICENSE",
     "README"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README",
     "Rakefile",
     "TODO",
     "VERSION",
     "lib/fotolia.rb",
     "lib/fotolia/base.rb",
     "lib/fotolia/categories.rb",
     "lib/fotolia/category.rb",
     "lib/fotolia/color.rb",
     "lib/fotolia/colors.rb",
     "lib/fotolia/conceptual_categories.rb",
     "lib/fotolia/conceptual_category.rb",
     "lib/fotolia/countries.rb",
     "lib/fotolia/country.rb",
     "lib/fotolia/galleries.rb",
     "lib/fotolia/gallery.rb",
     "lib/fotolia/language.rb",
     "lib/fotolia/medium.rb",
     "lib/fotolia/representative_categories.rb",
     "lib/fotolia/representative_category.rb",
     "lib/fotolia/search_result_set.rb",
     "lib/fotolia/tag.rb",
     "lib/fotolia/tags.rb",
     "lib/fotolia/user.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/tosch/fotolia}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Fotolia API Client}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
