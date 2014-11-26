# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'daodao/version'

Gem::Specification.new do |s|
  s.rubygems_version = '2.1.2'
  s.required_ruby_version = '>= 1.9.3'

  s.name              = 'daodao'
  s.version           = DaoDao::VERSION
  s.license           = 'MIT'

  s.summary           = "A tool for retrieving information from www.daodao.com"
  s.description       = "A tool for retrieving information from www.daodao.com"

  s.authors           = ["chengenbao"]
  s.email             = 'genbao.chen@gmail.com'
  s.homepage          = 'https://github.com/chengenbao/daodao.git'

  s.files             = `git ls-files -z`.split("\x0")
  s.executables       = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files        = s.files.grep(%r{^(test|spec|features)/})

  s.require_paths     = ["lib"]

  s.add_runtime_dependency('yajl-ruby',    "~> 1.1.0")
end
