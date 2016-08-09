# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = "texstylist"
  spec.version       = "0.0.1"

  spec.authors       = ["Deyan Ginev"]
  spec.email         = ["deyan@authorea.com"]

  spec.summary       = %q{A fully customizible stylist for TeX documents}
  spec.description   = %q{Produces a TeX document from a document+style specification pair. Use with the texstyles gem for easy access to hundreds of styles.}
  spec.homepage      = "https://github.com/Authorea/texstylist"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'escape_utils', '~> 1.2'
  spec.add_dependency 'json', '~> 1.8'
  spec.add_dependency 'stringex', '~> 2.5.2'
  spec.add_dependency 'texstyles', '~> 0.0.1'

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.1"

end
