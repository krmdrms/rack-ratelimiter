Rack Limiter
============
Simple redis-backed rack middleware to limit incoming http requests. Extracted from Screenfunk.com

## Configuration for Rails apps

Add rack-ratelimiter to your Gemfile

	  gem 'rack-racklimiter'

This will limit all incoming requests
    
    require 'rack/rate_limiter'
    config.middleware.use "Rack::RateLimiter", :interval => 60, :max_requests => 50, :redis_namespace => 'rack_limiter'

We have Public API @screenfunk which runs on the same rails instance with different domain

    config.middleware.use "Rack::RateLimiter", :interval => 60, :max_requests => 50, :redis_namespace => 'rack_limiter', :limit => {:domain => 'api.screenfunk.com'}

with :limit parameter server only limit requests for given domain.

#License
(The MIT License) Copyright © 2011 Kerem Durmus