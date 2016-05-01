$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ti_sqlegalize/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ti_sqlegalize"
  s.version     = TiSqlegalize::VERSION
  s.authors     = ["Emmanuel Bastien"]
  s.email       = ["os@ebastien.name"]
  s.homepage    = "https://github.com/opentraveldata"
  s.summary     = "RESTful SQL adapter"
  s.description = "TiSqlegalize provides a RESTful interface on top of a SQL engine."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 4.2.0"
  s.add_dependency "rails-api", "~> 0.3.1"
  s.add_dependency "sqliterate"
  s.add_dependency "ti_rails_auth"
  s.add_dependency "resque"
  s.add_dependency "cztop"

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "jsonpath"
  s.add_development_dependency "fabrication"
  s.add_development_dependency "mock_redis"
end
