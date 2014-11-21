# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_gift_certificate'
  s.version     = '2.2.6'
  s.summary     = 'Provide gift certificate functionality redeemable as store credit'
  s.description = 'Provide gift certificate functionality redeemable as store credit'
  s.required_ruby_version = '>= 1.9.3'

  s.authors   = ['Lucas S Eggers']
  s.email     = 'leggers@bombsheller.com'
  s.homepage  = 'http://www.bombsheller.com'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 2.2.4'
  s.add_dependency 'spree_store_credits'

  s.add_development_dependency 'capybara', '~> 2.1'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.4'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.13'
  s.add_development_dependency 'sass-rails', '~> 4.0.2'
  s.add_development_dependency 'capybara-webkit'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
