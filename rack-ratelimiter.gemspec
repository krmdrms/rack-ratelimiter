# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rack/rate_limiter/version"

Gem::Specification.new do |s|
  s.name        = "rack-ratelimiter"
  s.version     = RateLimiter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kerem Durmus"]
  s.email       = ["kerem@keremdurmus.com"]
  s.homepage    = "http://github.com/krmdrms/rack-ratelimiter"
  s.summary     = %q{simple rack middleware to limit incoming requests}
  s.description = %q{Redis backed rack middleware for rate-limiting http requests}
  
  s.rubyforge_project = "rack-ratelimiter"

  s.required_rubygems_version = ">= 1.3.6"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency 'rack', '>= 1.0.0'
  s.add_dependency 'redis-namespace', '>= 0.10.0'
  s.add_dependency "chronic", ">= 0.4.3"
end
