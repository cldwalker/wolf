# -*- encoding: utf-8 -*-
require 'rubygems' unless Object.const_defined?(:Gem)
require File.dirname(__FILE__) + "/lib/wolf/version"

Gem::Specification.new do |s|
  s.name        = "wolf"
  s.version     = Wolf::VERSION
  s.authors     = ["Gabriel Horner"]
  s.email       = "gabriel.horner@gmail.com"
  s.homepage    = "http://github.com/cldwalker/wolf"
  s.summary = "SUMMARY"
  s.description =  "DESCRIPTION"
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project = 'tagaholic'
  s.executables = ['wolf']
  s.add_dependency 'hirb', '>= 0.3.6'
  s.add_dependency 'wolfram', '>= 0.1.1'
  s.files = Dir.glob(%w[{lib,test}/**/*.rb bin/* [A-Z]*.{txt,rdoc} ext/**/*.{rb,c} **/deps.rip]) + %w{Rakefile .gemspec}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
  s.license = 'MIT'
end
