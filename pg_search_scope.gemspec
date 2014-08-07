# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pg_search_scope/version"

Gem::Specification.new do |gem|
  gem.name        = "pg_search_scope"
  gem.version     = PgSearchScope::VERSION
  gem.authors     = ['Ivan Efremov, Ilia Ablamonov, Cloud Castle Inc.']
  gem.email       = ['ilia@flamefork.ru', 'st8998@gmail.com']
  gem.homepage    = "https://github.com/cloudcastle/pg_search_scope"
  gem.summary     = %q{PostgreSQL full text search using Rails 3 scopes}
  gem.description = %q{}

  gem.add_dependency 'activerecord', '>= 3.2'
  gem.add_dependency 'activesupport', '>= 3.2'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']
end
