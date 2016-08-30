# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'endo/version'

Gem::Specification.new do |spec|
  spec.name          = "endo"
  spec.version       = Endo::VERSION
  spec.authors       = ["maruware"]
  spec.email         = ["maruware@maruware.com"]

  spec.summary       = %q{Testing api endpoints tool}
  spec.description   = %q{Testing api endpoints tool}
  spec.homepage      = "https://github.com/maruware/endo"

  spec.files         = `git ls-files`.split($/)
  spec.bindir        = "bin"
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.executables   = ['endo']
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "colorize"
  spec.add_runtime_dependency "ruby_dig"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "activesupport", "~> 4.2"
end
