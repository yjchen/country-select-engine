$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "country-select-engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "country-select-engine"
  s.version     = CountrySelectEngine::VERSION
  s.authors     = ["Yen-Ju Chen", "Kristian Mandrup"]
  s.email       = ["yjchenx@gmail.com", "kmandrup@gmail.com"]
  s.homepage    = ""
  s.summary     = "Rails engine for localized_country_select."
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rails", "~> 3.2.3"
  # s.add_dependency "hpricot"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
