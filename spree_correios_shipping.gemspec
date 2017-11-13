Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_correios_shipping'
  s.version     = '1.3.0'
  s.summary     = 'Extensão para cálculo de frete pelos correios'
  s.description = 'Extensão para cálculo de frete pelos correios'
  s.required_ruby_version = '>= 2.0.0'

  s.author        = ['Thiago Temple', 'Daniel Pakuschewski']
  s.email         = 'vintem@gmail.com'
  s.homepage      = 'http://github.com/Danielpk/spree-correios-shipping'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path  = 'lib'
  s.requirements  << 'none'

  s.add_dependency 'spree_core', '>= 3.4'
  s.add_dependency 'correios-frete', '~> 1.12'

  s.add_development_dependency 'database_cleaner', '1.6.2'
  s.add_development_dependency 'rspec-rails',  '~> 3.7.1'
  s.add_development_dependency 'pry'
end
