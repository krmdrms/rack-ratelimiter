require "rack"
require "redis/namespace"
require "json"

module Rack
  class RateLimiter
    def initialize(app, options={})
      @app = app
      @options ={
        :redis => nil,
        :limit => nil,
        :max_requests => 60, 
        :interval => 60, # in seconds
        :redis_namespace => 'rate_limiter'
      }.merge(options)
    end

    def call(env, options={})
      request = Rack::Request.new(env)
      status, headers, body = @app.call(env)

      return status, headers, body unless rate_limited?(request)

      begin
        key = generate_key(request)
        redis.setex(key, @options[:interval], @options[:max_requests]) unless redis.exists(key)
        @rate_remaining = redis.decr(key)
        @rate_reset_at = reset_at(redis.ttl(key))

        return limit_exceeded! if @rate_remaining < 0
      rescue ::Errno::ECONNREFUSED
        return [status, headers, body]
      end

      headers.merge!({'X-RateLimit-Limit' => @options[:max_requests].to_s,
                      'X-RateLimit-Remaining' => @rate_remaining.to_s,
                      'X-RateLimit-Reset' => @rate_reset_at.to_s
                    })

      return status, headers, body
    end

    def reset_at(ttl)
      time_now = Time.now.to_i
      time_now + ttl
    end

    def generate_key(request)
      "#{client_id(request)}"
    end

    def client_id(request)
      request.ip.to_s
    end

    def rate_limited?(request)
      limit = @options[:limit]

      unless limit[:domain].nil?
        return request.host == limit[:domain]
      end

      return false
    end

    def limit_exceeded!
      code = 403
      body = {:error => {:code => 403, :message => "Rate Limit Exceeded"}}.to_json
      [code, 
          {'Content-Type' => 'application/json; charset=utf-8',
           'Content-Lenght' => body.size.to_s
          }, body]
    end

    def redis
      if @options[:redis].nil?
        begin
          @redis = Redis::Namespace.new(@options[:redis_namespace], :redis => Redis.new(:thread_safe => true))
        rescue Errno::ECONNREFUSED
        end
      else
        @redis = @options[:redis]
      end
      @redis
    end
  end
end