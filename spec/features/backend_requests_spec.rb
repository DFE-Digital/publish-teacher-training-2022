require 'rails_helper'

describe 'requests made to mc-be' do
  describe 'the authorization header' do
    let(:provider1) { jsonapi :provider }
    let(:provider2) { jsonapi :provider }

    it 'is thread-safe' do
      # The api calls in this test should be completely isolated:
      # - request 1 + provider 1 + user 1 token
      # should not be in any way mixed up with:
      # - request 2 + provider 2 + user 2 token

      # This test simulates a thread-based race bug we found in the wild. Two
      # concurrent calls would result in the auth token of one user being used
      # for the call to the backend for a different user's request, resulting
      # in users seeing each-others' data. (This is bad).
      #
      # The token was being stored in Faraday's connection which it turns out
      # is not thread-safe, resulting in there only being a single place to
      # store the token for every request. The PR that adds this test also
      # changes the token storage to be explicitly thread-local.
      #
      # See class `MCBConnection` for the fix.
      #
      # Sequence of events:
      #
      #   - Request 1: start - sets the authorisation token for user1
      #   - Request 1: invoke the controller action which takes a little time
      #                opening it up to a race condition error
      #
      #   - - Request 2: begins while Request 1 is not yet complete (in
      #                  a separate thread)
      #   - - Request 2: overwrite the previous token (user1) as a part of
      #                  authentication
      #   - - Request 2: make the provider2 api call
      #   - - Request 2: allow the call to complete
      #
      #   The state is now corrupt as the user1 token has been overwritten by
      #   user2 token
      #
      #   - Request 1: allow the call to complete - this will use the wrong
      #                user token for its call to the backend api.

      stub_omniauth disable_completely: false

      # Stub extra dependencies, these calls are not under test here.
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

      # Stub the expected provider-code & token pairings.
      # The calls to the provider1 endpoint should use the user1 token,
      # calls to the provider2 endpoint should use the user2 token.
      #
      # By only stubbing these two exact combinations of provider_code and
      # token, any calls that use the wrong token for a provider will cause a
      # test failure (due to accessing a url+token combination that has no
      # stub). This is the assertion in this test, hence there is no further
      # explicit expect() in this test.
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

      # Intercept a call to `find` in the middle of the flow of a provider1
      # request so that we can introduce a concurrent api call for provider2.
      allow(Provider).to receive(:find)
                           .with(provider1.provider_code)
                           .and_wrap_original do |method, *args|
        thread = Thread.new do # thread2
          # stable JWT encoding mock
          allow(JWT).to receive(:encode).and_return('tokenUser2')
          # fire off a concurrent call to trigger the race condition:
          visit("/organisations/#{provider2.provider_code}")
        end
        # ensure the second call has completed so that shared state will have
        # been modified
        thread.join
        # allow thread1 to continue
        method.call(*args)
      end

      # Because we've intercepted the provider1 find call we need to still
      # allow the provider2 find call
      allow(Provider).to receive(:find)
                           .with(provider2.provider_code)
                           .and_call_original

      # stable JWT encoding mock
      allow(JWT).to receive(:encode).and_return('tokenUser1')

      # Fire off the provider1 call (the first of the two concurrent threads)
      visit("/organisations/#{provider1.provider_code}")
    end
  end
end
