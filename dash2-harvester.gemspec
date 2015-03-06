# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dash2/harvester/version'

Gem::Specification.new do |spec|
  spec.name          = 'dash2-harvester'
  spec.version       = Dash2::Harvester::VERSION
  spec.authors       = ['David Moles']
  spec.email         = ['david.moles@ucop.edu']
  spec.summary       = 'Harvests OAI-PMH metadata into Solr'
  spec.description   = 'Harvests OAI-PMH metadata from a digital repository into Solr for indexing'
  spec.homepage      = '' # TODO add homepage
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'simplecov' # TODO do we care about the version?
  spec.add_development_dependency 'simplecov-console' # TODO do we care about the version?

  spec.add_runtime_dependency 'oai', '~> 0.3.1'
end
