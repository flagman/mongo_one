Gem::Specification.new do |spec|
  spec.name = "mongo_one"
  spec.version = "0.1.0"
  spec.authors       = ["Pavel Malai"]
  spec.email         = ["flagmansupport@gmail.com"]
  spec.summary       = "A simple MongoDB ORM"
  spec.description   = "Provides a simple DSL for interacting with MongoDB"
  spec.homepage      = "https://github.com/flagman/mongo_one"
  spec.license       = "MIT"
  spec.files         = Dir.glob("lib/**/*", File::FNM_DOTMATCH)
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 3.2.1"
  spec.add_dependency 'dry-schema', '~> 1.13', '>= 1.13.2'
  spec.add_dependency 'dry-struct', '~> 1.6'
  spec.add_dependency 'dry-types', '~> 1.7', '>= 1.7.1'
  spec.add_dependency 'mongo', '~> 2.19', '>= 2.19.1'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
