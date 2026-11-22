lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'rails_simple_params/version'

Gem::Specification.new do |spec|
  spec.name     = 'rails_simple_params'
  spec.version  = RailsSimpleParams::VERSION
  spec.authors  = ['Jeremy Weathers']
  spec.email    = ['jeremy@codekindly.com']
  spec.homepage = 'https://github.com/jlw/rails_simple_params'
  spec.license  = 'MIT'
  spec.metadata = { 'rubygems_mfa_required' => 'true' }

  spec.summary = 'Parameter validation and type coercion for Rails'
  spec.description = 'Simple DSL to validate params (and coerce them to the desired type) that fall outside ' \
                     'of Rails\' default parameter whitelisting and ActiveModel validations system. The common ' \
                     'use cases are searching and sorting, whether from an HTML form or via a JSON API.'

  spec.files = Dir.glob('lib/**/*.rb') + %w[README.md]

  spec.rdoc_options = ['--charset=UTF-8']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.2.0'
  spec.required_rubygems_version = '>= 1.3.6'

  spec.add_dependency 'actionpack', '>= 7.0.1'
  spec.add_dependency 'activesupport', '>= 7.0.1'

  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'fuubar'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rspec-rails', '~> 3.4'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'simplecov'
end
