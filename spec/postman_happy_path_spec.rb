RSpec.describe MiniHawk::Client do
  # See https://docs.postman-echo.com/?version=latest#843acf02-a33c-c4bb-d742-c07b9212e4b0
  # Note that the host specified there (echo.getpostman.com) has changed to postman-echo.com

  let(:options) { {
    id:        'dh37fgj492je',
    key:       'werxhqb98rpaxn39848xrunpaw3489ruxnpa98w4rxn',
    algorithm: 'sha256',
    host:      'postman-echo.com',
    port:      443
  } }

  let(:header_options) { {
    resource: '/auth/hawk',
    ts:       '1572193973',
    nonce:    '62f65bd4',
  } }

  it "returns a valid header for the happy path to Postman" do
    expect(MiniHawk::Client.new(options).header(header_options)).to eq("Hawk id=\"dh37fgj492je\", ts=\"1572193973\", nonce=\"62f65bd4\", mac=\"ga3F99p/au5vaeA7Fh70XaJgbfItVql9Qv51HiWW6KA=\"")
  end
end
