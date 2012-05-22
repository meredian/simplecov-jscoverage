# -*- encoding: utf-8 -*-
require File.expand_path('../lib/simplecov-jscoverage/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Anton Sidelnikov"]
  gem.email         = ["ndmeredian@gmail.com"]
  gem.description   = %q{Layer for integrating JSCoverage results with SimpleCov}
  gem.summary       = %q{Layer for integrating JSCoverage results with SimpleCov}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "simplecov-jscoverage"
  gem.require_paths = ["lib"]
  gem.version       = SimpleCov::JSCoverage::VERSION

  gem.add_runtime_dependency 'therubyracer', '>= 0.10.0'

end
