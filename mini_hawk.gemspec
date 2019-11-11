$LOAD_PATH.unshift File.expand_path(File.join('..', 'lib'), __FILE__)
require 'mini_hawk/version'

Gem::Specification.new do |s|
  s.name          = 'mini_hawk'
  s.version       = MiniHawk::VERSION
  s.date          = Time.now.utc.strftime('%Y-%m-%d')
  s.summary       = 'Ruby Hawk client'
  s.description   = 'MiniHawk is a Ruby Hawk client based closely on the JavaScript client.'
  s.license       = 'MIT'
  s.authors       = ['John G. Norman']
  s.email         = 'john@7fff.com'
  s.files         = `git ls-files`.split("\n")
  s.homepage      = 'https://github.com/jgn/mini_hawk'
  s.rdoc_options  = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.test_files    = `git ls-files spec`.split("\n")
  s.add_dependency 'faraday-detailed_logger', '~> 2.1.3'
  s.add_dependency 'faraday_middleware',      '~> 0.13.1'
  s.add_dependency 'hashie',                  '~> 3.6.0'

  s.add_development_dependency 'rspec',       '~> 3.9.0'
  s.add_development_dependency 'pry',         '~> 0.12.2'
end
