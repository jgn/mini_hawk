require 'securerandom'
require 'base64'
require 'openssl'
require 'uri'

module MiniHawk
  class Client
    ALGORITHMS = [ 'sha1', 'sha256' ]
    OPTIONS = [ :id, :key, :ext, :uri, :host, :port, :algorithm ]
    REQUEST_OPTIONS = [ :resource, :method, :content_type, :payload, :ts, :nonce ]
    attr_reader *OPTIONS

    def initialize(options = {})
      options.each do |(key, value)|
        if OPTIONS.include?(key)
          instance_variable_set(:"@#{key}", value)
        else
          raise ArgumentError, "Unknown option: '#{key}'"
        end
      end
      @algorithm = options[:algorithm] || 'sha256'

      raise InvalidCrendentialsError unless id && key
      raise UnknownAlgorithmError unless ALGORITHMS.include?(algorithm)

      if uri
        @host = uri.host
        @port = uri.port
      end
      raise ArgumentError unless host && port
    end

    def header(request_options)
      request_options.each do |(key, value)|
        if !REQUEST_OPTIONS.include?(key)
          raise ArgumentError, "Unknown request option: '#{key}'"
        end
      end

      request_options[:method] ||= 'get'
      request_options[:content_type] ||= 'application/json'
      request_options[:ts] ||= Time.now.to_i
      request_options[:nonce] ||= SecureRandom.hex(4)
      request_options[:ext] = ext if ext
      request_options[:host] = host
      request_options[:port] = port

      @request_options = request_options

      args = {
        id: id,
        ts: request_options[:ts],
        nonce: request_options[:nonce],
      }
      args[:hash] = Utils.hash(algorithm, request_options) if request_options[:payload]
      args[:ext] = request_options[:ext] if request_options[:ext]
      args[:mac] = Utils.mac(algorithm, key, request_options)

      "Hawk " + args.map { |(k,v)| "#{k}=\"#{v}\"" }.join(', ')
    end
    
    def authenticate(request_details_from_server, response_headers, payload)
      case
      when response_headers['www-authenticate']
         # Can't handle this yet
      when response_headers['server-authorization']
        server_auth_attributes = Utils.parse_authorization_header(response_headers['server-authorization'])
        request_details_from_server[:ext] = server_auth_attributes['ext']
        request_details_from_server[:content_type] = response_headers['content-type']
        computed_mac = Utils.mac(algorithm, key, request_details_from_server, server_auth_attributes['hash'], 'response')
        raise ArgumentError, 'Bad response mac' unless computed_mac == server_auth_attributes['mac']
      else
        # neither of the headers we can deal with; in the JS version, the option "required" means:
        # raise an exception if server-authorization is not present
      end
    end

    def request_details
      @request_options
    end
  end
end
