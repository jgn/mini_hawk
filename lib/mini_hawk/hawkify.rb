require 'faraday_middleware'

module MiniHawk
  class Hawkify < Faraday::Response::Middleware
    attr_reader :id, :key, :ext, :algorithm, :hawkify_options

    def initialize(app, id, key, ext = nil, algorithm = 'sha256', hawkify_options = { authenticate_server_response: true })
      super(app)
      @id, @key, @ext, @algorithm, @hawkify_options = id, key, ext, algorithm, hawkify_options
    end

    def call(env)
      uri = env['url']
      client_options = { id: id, key: key, ext: ext, algorithm: algorithm, uri: uri }
      @mini_hawk_client ||= Client.new(client_options)

      resource = uri.path
      resource = resource + '?' + uri.query if uri.query
      method = env['method']
      payload = env['body']
      # TODO: Should the request content-type be set based on something from env?
      env[:request_headers]['Authorization'] = @mini_hawk_client.header(
        resource: resource, method: method, content_type: 'application/json', payload: payload
      )
      # keep some of the incoming options so we can use them when checking response
      if hawkify_options[:authenticate_server_response]
        request_details = @mini_hawk_client.request_details
        env['hawkify_request_details'] = request_details
      end


      @app.call(env).on_complete do |response_env|
        if response_env['hawkify_request_details']
          if response_env[:raw_body]
            request_details = response_env['hawkify_request_details']
            @mini_hawk_client.authenticate(request_details, response_env.response_headers, response_env[:raw_body])
            puts "request_details: #{request_details.inspect}"
            puts "headers: #{response_env.response_headers.inspect}"
            puts "payload: #{payload}"
          end
        end
      end
    end
  end
end
Faraday::Middleware.register_middleware hawkify: MiniHawk::Hawkify
Faraday::Request.register_middleware hawkify: MiniHawk::Hawkify
