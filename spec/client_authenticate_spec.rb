module MiniHawk
  RSpec.describe Client do
    context 'hawk client authenticate (following hapijs/hawk tests)' do
      let (:options) { {
        id: '123456',
        key: 'werxhqb98rpaxn39848xrunpaw3489ruxnpa98w4rxn',
        ext: 'ext',
        algorithm: 'sha256',
        host: 'example.com',
        port: 8000
      }}
      describe '.authenticate' do
        it 'rejects on invalid header' do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L180
          expect { Client.new(options).authenticate(
            options,
            {
              'content-type' => 'text/plain',
              'server-authorization' => 'Hawk mac="_IJRsMl/4oL+nn+vKoeVZPdCHXB4yJkNnBbTbHFZUYE=", hash="f9cDF/TDm7TkYRLnGwRMfeDzT6LixQVLvrIKhh0vgmM=", ext="response-specific", bad="foo"'
            },
            nil
          ) }.to raise_error(ArgumentError, "Unknown attribute key: 'bad'");
        end
        it 'rejects an invalid mac' do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L214
          headers = {
            'content-type' => 'text/plain',
            'server-authorization' => 'Hawk mac="_IJRsMl/4oL+nn+vKoeVZPdCHXB4yJkNnBbTbHFZUYE=", hash="f9cDF/TDm7TkYRLnGwRMfeDzT6LixQVLvrIKhh0vgmM=", ext="response-specific"'
          }
          artifacts = {
            method: 'POST',
            resource: '/resource/4?filter=a',
            ts: '1362336900',
            nonce: 'eb5S_L',
            hash: 'nJjkVtBE5Y/Bk38Aiokwn0jiJxt/0S2WRSUwWLCf5xk=',
            mac: 'BlmSe8K+pbKIb6YsZCnt4E1GrYvY1AaYayNR82dGpIk=',
          }
          expect { Client.new(options).authenticate(artifacts, headers, nil) }.to raise_error(ArgumentError, "Bad response mac");
        end
        # xit 'returns headers on ignoring hash' do
        #   artifacts = {
        #         method: 'POST',
        #         host: 'example.com',
        #         port: '8080',
        #         resource: '/resource/4?filter=a',
        #         ts: '1362336900',
        #         nonce: 'eb5S_L',
        #         hash: 'nJjkVtBE5Y/Bk38Aiokwn0jiJxt/0S2WRSUwWLCf5xk=',
        #         ext: 'some-app-data',
        #         app: undefined,
        #         dlg: undefined,
        #         mac: 'BlmSe8K+pbKIb6YsZCnt4E1GrYvY1AaYayNR82dGpIk=',
        #         id: '123456'
        #     }
        #     credentials = {
        #         id: '123456',
        #         key: 'werxhqb98rpaxn39848xrunpaw3489ruxnpa98w4rxn',
        #         algorithm: 'sha256',
        #         user: 'steve'
        #     }
        #   # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L249
        # end
        xit 'validates response payload' do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L292
        end
        xit 'errors on invalid response payload' do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L334
        end
        xit 'fails on invalid WWW-Authenticate header format' do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L334
        end
        xit 'fails on an invalid server timestamp hash' do
          # In the JavaScript test, "it" is given as "fails on invalid WWW-Authenticate header format"
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L353
        end
        xit 'skips tsm validation when missing ts' do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L360
        end
        xit 'errors on missing server-authorization header' do
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L393
        end
      end
    end
  end
end
