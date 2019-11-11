module MiniHawk
  RSpec.describe Client do
    context 'hawk (javascript) readme' do
      let(:options) { {
        id:        'dh37fgj492je',
        key:       'werxhqb98rpaxn39848xrunpaw3489ruxnpa98w4rxn',
        algorithm: 'sha256',
        ext:       'some-app-ext-data',
        host:      'example.com',
        port:      '8000'
      } }
      describe ".header" do
        it "returns a correct authorization header" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/readme.js#L36
          expect(Client.new(options).header(
            resource: '/resource/1?b=1&a=2',
            ts:       '1353832234',
            nonce:    'j4h3g2',
          )).to eq('Hawk id="dh37fgj492je", ts="1353832234", nonce="j4h3g2", ext="some-app-ext-data", mac="6R4rV5iE+NPoym+WwjeHzjAGXUtLNIxmo1vpMofpLAE="')
        end
      end
      describe "#hash" do
        # Apparently not tested in hapijs/hawk
        it "generates a correct hash" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/readme.js#L36
          mini_hawk = Client.new(id: 'foo', key: 'bar', host: 'google.com', port: 80)
          expect(Utils.hash('sha256',
            content_type: 'text/plain',
            payload: 'Thank you for flying Hawk')).to eq('Yi9LfIIFRtBEPt74PVmbTF/xVAwPn7ub15ePICfgnuY=')
        end
      end
      describe "#normalized_string" do
        it "returns a correct normalized string" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/readme.js#L52
          # options[:method] = 'get'
          # options[:resource] = '/resource/1?b=1&a=2'
          # options[:host] = 'example.com'
          # options[:port] = 8000
          mini_hawk = Client.new(options)
          expect(Utils.normalized_string(options[:algorithm], {
            host: 'example.com',
            port: 8000,
            resource: '/resource/1?b=1&a=2',
            method: 'get',
            ts:        '1353832234',
            nonce:     'j4h3g2',
            ext: 'some-app-ext-data'
          })).to eq("hawk.1.header\n1353832234\nj4h3g2\nGET\n/resource/1?b=1&a=2\nexample.com\n8000\n\nsome-app-ext-data\n")
        end
      end
      describe ".header with payload" do
        it "returns a correct authorization header" do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/readme.js#L62
          expect(Client.new(options).header(
            resource: '/resource/1?b=1&a=2',
            method: 'post',
            content_type: 'text/plain',
            payload: 'Thank you for flying Hawk',
            ts:        '1353832234',
            nonce:     'j4h3g2'
            )).to eq('Hawk id="dh37fgj492je", ts="1353832234", nonce="j4h3g2", hash="Yi9LfIIFRtBEPt74PVmbTF/xVAwPn7ub15ePICfgnuY=", ext="some-app-ext-data", mac="aSe1DERmZuRl3pI36/9BdZmnErTw3sNzOOAUlfeKjVw="')
        end
      end
    end
  end
end
