module MiniHawk
  RSpec.describe Utils do
    context 'hawk utils (following hapijs/hawk tests)' do
      describe '.parse_authorization_header' do
        # This method is essentially untested in the JavaScript version, and is
        # verified via Client.authenticate
        it 'rejects an empty header' do
          expect { Utils.parse_authorization_header(nil) }.to raise_error(ArgumentError)
        end

        it 'rejects a header with an invalid scheme' do
          expect { Utils.parse_authorization_header('Heck') }.to raise_error(ArgumentError)
        end

        it 'rejects a header with only a scheme' do
          expect { Utils.parse_authorization_header('Hawk') }.to raise_error(ArgumentError)
        end

        it 'rejects a header with a disallowed character in the attribute value' do
          expect { Utils.parse_authorization_header('Hawk mac="abc", nonce=""') }.to raise_error(ArgumentError, 'Disallowed character')
        end

        it 'rejects a header with an unknown attribute key' do
          expect { Utils.parse_authorization_header('Hawk mac="abc", bad="xyz"') }.to raise_error(ArgumentError, "Unknown attribute key: 'bad'")
        end
      end
    end
  end
end
