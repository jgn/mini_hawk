module MiniHawk

  # bundle exec rspec --tag threat_stack spec/threatstack_happy_path_spec.rb

  RSpec.describe "ThreatStack happy path" do
    context "Happy path based on ThreatStack example", :threat_stack do

      let(:options) { {
      id:        ENV['THREATSTACK_USER_ID'],
      key:       ENV['THREATSTACK_API_KEY'],
      ext:       ENV['THREATSTACK_ORGANIZATION_ID'],
      algorithm: 'sha256',
      host:      'api.threatstack.com',
      port:      443
      } }

      it "returns a valid header for the happy path to ThreatStack" do
        expect(Client.new(options).header(
          resource: '/help/hawk/self-test',
          ts:       '1572704161',
          nonce:    '110909d3',
        )).to eq("Hawk id=\"563b7bf374c815ce60e67e50\", ts=\"1572704161\", nonce=\"110909d3\", ext=\"5537c4284e9684df7e000014\", mac=\"7Wl8mqmrWJMyTnziMZnYOI7V/6f8th9S3kWjuvnMwZc=\"")
      end

      let(:request_details_from_server) { {
        resource: "/help/hawk/self-test",
        method: :get,
        content_type: "application/json",
        ts: 1572704161,
        nonce: "110909d3",
        ext: nil,
        host: "api.threatstack.com",
        port: 443
      } }

      let(:response_headers) { {
        'server-authorization' => "Hawk mac=\"hrKWB747psu757J4C3THRQc+htVTePuoTXbs6rONS7o=\", hash=\"8ONUzoGGeYaAi6rb6f9dqc8NasvCfMHwxzl1M3CqZA4=\""
      } }

      let(:payload) { '{"authenticated\:true}' }

      it "authenticates a valid Hawk header generated by the server" do
        expect { Client.new(options).authenticate(request_details_from_server, response_headers, payload) }.not_to raise_error
      end

      it "raises an exception when a server returns an invalild Hawk header" do
        response_headers['server-authorization'].gsub!('hash="', 'hash="bogus')

        expect { Client.new(options).authenticate(
          request_details_from_server,
          response_headers,
          payload
        ) }.to raise_error(ArgumentError, 'Bad response mac')
      end

    end
  end
end
