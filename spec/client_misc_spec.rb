module MiniHawk
  RSpec.describe Utils do
    context 'hawk client misc (not in hapijs/hawk tests)' do
      describe ".hash" do
        it "returns a correct hash" do
          # Apparently not tested directly in hapjs/hawk
          # https://github.com/hapijs/hawk/blob/f455587c08c46d7249e334a4fe5fb70230e6bc3b/test/client.js#L28
          expect(Utils.hash('sha1',
          {
            content_type: '',
            payload: 'something to write about'
          }
          )).to eq("bsvY3IfUllw6V5rvk4tStEvpBhE=")
        end
      end
    end
  end
end
