# Rack::Attack configuration for rate limiting
if defined?(Rack::Attack)
  class Rack::Attack
    # Configure cache store (uses Rails cache store by default)
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

    # Throttle file uploads
    throttle('file_uploads/ip', limit: 20, period: 1.minute) do |req|
      # Only apply to message creation endpoints with file uploads
      if req.path.match?(%r{/channels/\d+/messages}) && req.post?
        req.ip
      end
    end

    # Throttle message creation
    throttle('messages/ip', limit: 60, period: 1.minute) do |req|
      if req.path.match?(%r{/channels/\d+/messages}) && req.post?
        req.ip
      end
    end

    # Custom response for rate limited requests
    self.throttled_responder = lambda do |env|
      [429, { 'Content-Type' => 'application/json' }, [{ error: '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.' }.to_json]]
    end
  end

  # Enable Rack::Attack
  Rails.application.config.middleware.use Rack::Attack
end