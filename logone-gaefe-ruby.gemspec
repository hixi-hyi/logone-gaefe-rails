# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "logone/gaefe/rails/version"

Gem::Specification.new do |spec|
  spec.name          = "logone-gaefe-rails"
  spec.version       = Logone::Gaefe::Rails::VERSION
  spec.authors       = ["Hiroyoshi Houchi"]
  spec.email         = ["git@hixi-hyi.com"]

  spec.summary       = %q{The library is the logger that supported structed logging per request in GAEFE.}
  spec.homepage      = "https://github.com/hixi-hyi/logone-gaefe-rails"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

end
