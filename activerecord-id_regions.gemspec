# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record/id_regions/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-id_regions"
  spec.version       = ActiveRecord::IdRegions::VERSION
  spec.authors       = ["ManageIQ Developers"]

  spec.summary       = %q{ActiveRecord extension to allow partitioning ids into regions, for merge replication purposes}
  spec.description   = %q{ActiveRecord extension to allow partitioning ids into regions, for merge replication purposes}
  spec.homepage      = "https://github.com/ManageIQ/activerecord-id_regions"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord",  ">= 7.0.8", "<8.0"
  spec.add_dependency "activesupport", ">= 7.0.8", "<8.0"
  spec.add_dependency "pg"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "manageiq-style"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", ">= 0.21.2"
end
