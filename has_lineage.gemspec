# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'has_lineage/version'

Gem::Specification.new do |spec|
  spec.name          = "has_lineage"
  spec.version       = HasLineage::VERSION
  spec.authors       = ["Tim Hemi"]
  spec.email         = ["tim@reinteractive.net"]
  spec.description   = "Lineage is a hybrid hierarchy data storage pattern"
  spec.summary       = "Lineage uses Nested Sets and Materialised Path for optumim hierarchical SQL query methods"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end