require "test/test_helper"

class RackLimiterTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    @app = TestApp.new
    @rack = Rack::RateLimiter.new(@app, {
      :interval => 60,
      :max_requests => 5,
      :redis_namespace => 'rack_limiter_test',
      :limit => {:domain => 'api.example.com'}
      }
    )
  end

  def redis
    @redis = Redis::Namespace.new('rack_limiter_test', :redis => Redis.new)
  end

  def flush_redis!
    redis.keys("*").each do |key|
      redis.del(key)
    end
  end

  def setup
    flush_redis!
  end

  def test_request
    get 'http://example.com/'
    
    assert_equal 200, last_response.status
    assert_equal "Hello, World!", last_response.body
  end

  def test_rate_limited_request
    5.times do 
      get 'http://api.example.com/'
      assert_equal 200, last_response.status
    end

    get 'http://api.example.com/'
    body = {:error => {:code => 403, :message => "Rate Limit Exceeded"}}.to_json
    assert_equal 403, last_response.status
    assert_equal body, last_response.body
  end

  def test_rate_limited?
    10.times do 
      get 'http://hello.example.com/'
      assert_equal 200, last_response.status
    end
  end

  class TestApp
    def call(env)
      [200, {
        'Content-Type' => 'text/html; charset=utf-8',
      }, ["Hello, World!"]]
    end
  end
end