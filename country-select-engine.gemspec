$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "country-select-engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "country-select-engine"
  s.version     = CountrySelectEngine::VERSION
  s.authors     = ["Yen-Ju Chen", "Kristian Mandrup"]
  s.email       = ["yjchenx@gmail.com", "kmandrup@gmail.com"]
  s.homepage    = "https://github.com/yjchen/country-select-engine"
  s.summary     = "Rails engine for localized_country_select."
  s.description = "Provide a list of localized countries, currencies and time zones"
  s.license = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
#  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.signing_key = File.join(Dir.home,'/.gem/trust/gem-private_key.pem')
  s.cert_chain = ['gem-public_cert.pem']

  s.add_dependency "rails", ">= 4.0.0"

  s.add_development_dependency "sqlite3"
end
