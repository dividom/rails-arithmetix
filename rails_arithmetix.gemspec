$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails_arithmetix/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails_arithmetix"
  s.version     = RailsArithmetix::VERSION
  s.authors     = [""]
  s.email       = ["jeremie@dividom.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of RailsArithmetix."
  s.description = "TODO: Description of RailsArithmetix."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.5.2"

  s.add_development_dependency "sqlite3"
end
