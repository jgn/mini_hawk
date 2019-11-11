module MiniHawk
  class Utils
    DEFAULT_KEYS = ['id', 'ts', 'nonce', 'hash', 'ext', 'mac', 'app', 'dlg']
    ALLOWED_VALUE_CHARS = /^[ \w\!#\$%&'\(\)\*\+,\-\.\/\:;<\=>\?@\[\]\^`\{\|\}~]+$/

    def self.parse_authorization_header(header, keys = nil)
      # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/lib/utils.js#L118
      raise ArgumentError unless header

      scheme, match, attribute_string = header.partition(/\s+/)
      # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/lib/utils.js#L127
      raise ArgumentError, 'Invalid header syntax' if attribute_string.size == 0

      # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/lib/utils.js#L132
      raise ArgumentError unless scheme =~ /hawk/i

      attributes = {}
      keys ||= DEFAULT_KEYS

      while attribute_string.length > 0 do
        key, match, attribute_string = attribute_string.partition('=')
        key.strip!
        attribute_string.strip!
        # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/lib/utils.js#L147
        raise ArgumentError, "Unknown attribute key: '#{key}'" unless keys.include?(key)

        # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/lib/utils.js#L161
        raise ArgumentError, 'Duplicate attribute key' if attributes[key]
        
        raise 'Invalid header syntax' unless attribute_string[0] == '"'
        attribute_string = attribute_string[1..-1]
        value, match, attribute_string = attribute_string.partition('"')

        # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/lib/utils.js#L154
        raise ArgumentError, 'Disallowed character' unless value =~ ALLOWED_VALUE_CHARS

        attributes[key] = value

        should_be_empty, match, attribute_string = attribute_string.partition(",")
        should_be_empty.strip!
        attribute_string.strip!
        raise ArgumentError, 'Missing comma after "' unless should_be_empty.length == 0
      end

      attributes

    end

    def self.mac(algorithm, key, options, hash = nil, type = 'header')
      Base64.encode64(OpenSSL::HMAC.digest(algorithm, key, normalized_string(algorithm, options, hash, type))).chomp
    end

    def self.normalized_string(algorithm, options, hash = nil, type = 'header')
      [
        "hawk.1.#{type}",
        options[:ts],
        options[:nonce],
        options[:method].to_s.upcase,
        options[:resource],
        options[:host],
        options[:port],
        hash || hash(algorithm, options),
        options[:ext],
        nil
      ].join("\n")
    end

    def self.hash(algorithm, options)
      if options[:payload]
        payload_normalized_string = [
          'hawk.1.payload',
          options[:content_type],
          options[:payload],
          nil
        ].join("\n")
        Base64.encode64(OpenSSL::Digest.digest(algorithm, payload_normalized_string)).chomp
      else
        ""
      end
    end

  end
end
