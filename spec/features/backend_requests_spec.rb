require 'rails_helper'

describe 'requests made to mc-be' do
  describe 'the authorization header' do
    let(:provider1) { jsonapi :provider }
    let(:provider2) { jsonapi :provider }

    it 'is thread-safe' do
      stub_omniauth disable_completely: false
      stub_session_create
      stub_api_v2_request(
        '/providers',
        jsonapi(:providers_response, data: [provider1, provider2]),
        token: 'tokenUser1'
      )
      stub_api_v2_request(
        '/providers',
        jsonapi(:providers_response, data: [provider1, provider2]),
        token: 'tokenUser2'
      )
      stub_api_v2_request(
        "/providers/#{provider1.provider_code}",
        provider1.render,
        token: 'tokenUser1'
      )
      stub_api_v2_request(
        "/providers/#{provider2.provider_code}",
        provider2.render,
        token: 'tokenUser2'
      )

      allow(Provider).to receive(:find)
                           .with(provider1.provider_code)
                           .and_wrap_original do |method, *args|
        # This simulates a bug we found in the wild:
        #
        #   - Request 1: start and set the authorisation token for user2 on the
        #                Faraday connection
        #   - Request 1: invoke the controller action which takes a little time
        #                opening it up to a race condition error
        #   - Request 2: start and set the authorisation token for user2 on the
        #                Faraday connection
        #   - Request 1: connect to manage-courses backend with user1's token
        thread = Thread.new do
          allow(JWT).to receive(:encode).and_return('tokenUser2')
          visit("/organisations/#{provider2.provider_code}")
        end
        thread.join
        method.call(*args)
      end

      allow(Provider).to receive(:find)
                           .with(provider2.provider_code)
                           .and_call_original

      allow(JWT).to receive(:encode).and_return('tokenUser1')
      visit("/organisations/#{provider1.provider_code}")
    end
  end
end
