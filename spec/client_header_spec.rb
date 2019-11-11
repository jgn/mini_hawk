module MiniHawk
  RSpec.describe Client do
    context 'hawk client header (following hapijs/hawk tests)' do
      let(:credentials) { {
      } }
      let(:options) { {
        id:        '123456',
        key:       '2983d45yun89q',
        ext:          'Bazinga!',
        host: 'example.net',
        port: 80,
        algorithm: 'sha1'
      } }
      let(:options_sha256) {
        options.tap do |options|
          options[:port] = 443
          options[:algorithm] = 'sha256'
        end
      }
      let(:options_no_ext) {
        options.tap do |options|
          options.delete(:ext)
          options[:port] = 443
          options[:algorithm] = 'sha256'
        end
      }
      let(:options_nil_ext) {
        options.tap do |options|
          options[:ext] = nil
          options[:port] = 443
          options[:algorithm] = 'sha256'
        end
      }
      let(:options_empty_payload) {
        options.tap do |options|
          options[:ext] = nil
          options[:port] = 443
          options[:algorithm] = 'sha256'
        end
      }
      let(:options_pre_hashed_payload) {
        options.tap do |options|
          options[:ext] = nil
          options[:algorithm] = 'sha256'
        end
      }
      
      describe ".header" do
        it "returns a valid authorization header (sha1)" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L28
          expect(Client.new(options).header(
            resource:     '/somewhere/over/the/rainbow',
            method:       'POST',
            ts:           '1353809207',
            nonce:        'Ygvqdz',
            payload:      'something to write about',
            content_type: ''
            )).to eq('Hawk id="123456", ts="1353809207", nonce="Ygvqdz", hash="bsvY3IfUllw6V5rvk4tStEvpBhE=", ext="Bazinga!", mac="qbf1ZPG/r/e06F4ht+T77LXi5vw="')
        end
        it "returns a valid authorization header (sha256)" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L40
          expect(Client.new(options_sha256).header(
            resource:     '/somewhere/over/the/rainbow',
            method:       'POST',
            ts:           '1353809207',
            nonce:        'Ygvqdz',
            payload:      'something to write about',
            content_type: 'text/plain'
            )).to eq('Hawk id="123456", ts="1353809207", nonce="Ygvqdz", hash="2QfCt3GuY9HQnHWyWD3wX68ZOKbynqlfYmuO2ZBRqtY=", ext="Bazinga!", mac="q1CwFoSHzPZSkbIvl0oYlD+91rBUEvFk763nMjMndj8="')
        end
        it "returns a valid authorization header (no ext)" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L52
          expect(Client.new(options_no_ext).header(
            resource:     '/somewhere/over/the/rainbow',
            method:       'POST',
            ts:           '1353809207',
            nonce:        'Ygvqdz',
            payload:      'something to write about',
            content_type: 'text/plain'
          )).to eq('Hawk id="123456", ts="1353809207", nonce="Ygvqdz", hash="2QfCt3GuY9HQnHWyWD3wX68ZOKbynqlfYmuO2ZBRqtY=", mac="HTgtd0jPI6E4izx8e4OHdO36q00xFCU0FolNq3RiCYs="')
        end
        it "returns a valid authorization header (null ext)" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L64
          expect(Client.new(options_nil_ext).header(
            resource:     '/somewhere/over/the/rainbow',
            method:       'POST',
            ts:           '1353809207',
            nonce:        'Ygvqdz',
            payload:      'something to write about',
            content_type: 'text/plain'
            )).to eq('Hawk id="123456", ts="1353809207", nonce="Ygvqdz", hash="2QfCt3GuY9HQnHWyWD3wX68ZOKbynqlfYmuO2ZBRqtY=", mac="HTgtd0jPI6E4izx8e4OHdO36q00xFCU0FolNq3RiCYs="')
        end
        it "returns a valid authorization header (empty payload)" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L76
          expect(Client.new(options_empty_payload).header(
              resource:     '/somewhere/over/the/rainbow',
              method:       'POST',
              ts:           '1353809207',
              nonce:        'Ygvqdz',
              payload:      '',
              content_type: 'text/plain'
            )).to eq("Hawk id=\"123456\", ts=\"1353809207\", nonce=\"Ygvqdz\", hash=\"q/t+NNAkQZNlq/aAD6PlexImwQTxwgT2MahfTa9XRLA=\", mac=\"U5k16YEzn3UnBHKeBzsDXn067Gu3R4YaY6xOt9PYRZM=\"")
        end
        it "returns a valid authorization header (pre hashed payload)" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L90
          # Have no idea what the meaning of this test is
          client = Client.new(
            id: '123456',
            key: '2983d45yun89q',
            host: 'example.net',
            port: 443
          )
          expect(client.header(
              resource: '/somewhere/over/the/rainbow',
              method: 'POST',
              ts: '1353809207',
              nonce: 'Ygvqdz',
              content_type: 'text/plain',
              payload: 'something to write about'
              )).to eq('Hawk id="123456", ts="1353809207", nonce="Ygvqdz", hash="2QfCt3GuY9HQnHWyWD3wX68ZOKbynqlfYmuO2ZBRqtY=", mac="HTgtd0jPI6E4izx8e4OHdO36q00xFCU0FolNq3RiCYs="')
        end
        
        # Arguably to follow the JavaScript code, these should raise StandardError
        it "errors on missing uri" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L95
          expect { Client.new(id: 'foo', key: 'bar') }.to raise_error(ArgumentError)
        end
        it "errors on invalid uri" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L100
          # Skipping: Now requiring host and port, and doesn't fit with Ruby duck-typing
          # expect { Client.new.header(4, 'POST') }.to raise_error(ArgumentError)
        end
        it "errors on missing method" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L105
          # skipping because now providing a default
          # expect { Client.new.header('https://example.net/somewhere/over/the/rainbow', '') }.to raise_error(ArgumentError)
        end
        it "errors on invalid method" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L110
          # Skpping: Not the Ruby way
          # expect { Client.new(id: 'foo', key: 'bar', host: 'example.net', port: 80).header(
          #   resource: '/somewhere/over/the/rainbow',
          #   method: 5
          #  ) }.to raise_error(ArgumentError)
        end
        # it "errors on missing options" do
        #   # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L115
        #   expect { Client.new.header('https://example.net/somewhere/over/the/rainbow', 'POST') }.to raise_error(ArgumentError)
        # end
        it "errors on invalid options" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L120
          # Skipping: Typing checking is not the Ruby way
          # expect { Client.new('boo') }.to raise_error(ArgumentError)
        end
        it "errors on invalid credentials (id)" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L130
          expect { Client.new(key: '2983d45yun89q', algorithm: 'sha256', ext: 'Bazinga!') }.to raise_error(MiniHawk::InvalidCrendentialsError)
        end
        it "errors on missing credentials" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L135
          expect { Client.new(ext: 'Bazinga!') }.to raise_error(MiniHawk::InvalidCrendentialsError)
        end
        it "errors on invalid credentials (key)" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L145
          expect { Client.new(id: '123456', algorithm: 'sha256', ext: 'Bazinga!') }.to raise_error(MiniHawk::InvalidCrendentialsError)
        end
        xit "errors on invalid credentials (algorithm)" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L155
          # Skipping this because we are now providing a default
          expect { Client.new(id: '123456', key: '2983d45yun89q') }.to raise_error(MiniHawk::InvalidCrendentialsError)
        end
        it "errors on invalid algorithm" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L166
          expect { Client.new(id: '123456', key: '2983d45yun89q', algorithm: 'hmac-sha-0') }.to raise_error(MiniHawk::UnknownAlgorithmError)
        end
        it "does not error on a valid algorithm" do
          # Not checked in hapijs/hawk
          expect { Client.new(id: '123456', key: '2983d45yun89q', host: 'example.net', port: 80, algorithm: 'sha256') }.not_to raise_error
        end
      end
    end
  end
end
