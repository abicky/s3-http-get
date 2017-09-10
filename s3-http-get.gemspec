# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "s3-http-get/version"

Gem::Specification.new do |spec|
  spec.name          = "s3-http-get"
  spec.version       = S3HttpGet::VERSION
  spec.authors       = ["abicky"]
  spec.email         = ["takeshi.arabiki@gmail.com"]

  spec.summary       = %q{Get S3 objects using REST API}
  spec.description   = %q{Get S3 objects using REST API}
  spec.homepage      = "https://github.com/abicky/s3-http-get"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "aws-sdk-core", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
