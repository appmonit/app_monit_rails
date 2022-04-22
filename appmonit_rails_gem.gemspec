# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'app_monit/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "app_monit_rails"
  spec.version       = AppMonit::Rails::VERSION
  spec.authors       = ["Redmar Kerkhoff", "Benoist Claassen"]
  spec.email         = ["redmar@appmon.it", "benoist@appmon.it"]
  spec.summary       = %q{Client gem for pushing events from ruby to the appmon.it service}
  spec.description   = %q{Client gem for pushing events from ruby to the appmon.it service}
  spec.homepage      = "https://appmon.it"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "app_monit", ">= 0.0.7"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "rails"
end
