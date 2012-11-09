# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruhue/version'

Gem::Specification.new do |gem|
  gem.name          = "ruhue"
  gem.summary       = %q{API client for interacting with the Philips Hue Hub HTTP API.}

  gem.homepage      = "https://github.com/Burgestrand/ruhue"
  gem.authors       = ["Kim Burgestrand"]
  gem.email         = ["kim@burgestrand.se"]
  gem.license       = "MIT License"

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.version       = Ruhue::VERSION

  gem.add_dependency 'httpi'
  gem.add_dependency 'nokogiri'
  gem.add_development_dependency 'rspec'
end
