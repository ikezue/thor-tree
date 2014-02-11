# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'thor/tree/version'

Gem::Specification.new do |gem|
  gem.name          = 'thor-tree'
  gem.version       = Thor::Tree::VERSION
  gem.authors       = ['ikezue']
  gem.email         = ['ikezue@gmail.com']
  gem.description   = %q{A thor extension for generating directory structures from file trees defined in YAML}
  gem.summary       = gem.description
  gem.homepage      = 'https://github.com/ikezue/thor-tree'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency             'path',      '~> 1.3.1'
  gem.add_dependency             'safe_yaml', '~> 0.9.4'
  gem.add_dependency             'thor',      '~> 0.18.1'
  gem.add_development_dependency 'bundler',   '~> 1.5.2'
  gem.add_development_dependency 'rake',      '~> 10.1.0'
  gem.add_development_dependency 'rspec',     '~> 2.14.1'
end
