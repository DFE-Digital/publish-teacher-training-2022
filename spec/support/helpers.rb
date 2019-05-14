module Helpers
  def stub_omniauth(user: nil)
    user ||= build(:user)

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:dfe] = {
      'provider' => 'dfe',
      'uid'      => SecureRandom.uuid,
      'info'     => {
        'first_name' => user.first_name,
        'last_name'  => user.last_name,
        'email'      => user.email,
        'id'         => user.id,
        'state'      => user.state
      },
      'credentials' => {
        'token_id' => '123'
      }
    }

    # This is needed because we check the provider count on all pages
    # TODO: Move this to be returned with the user.
    stub_api_v2_request('/providers', jsonapi(:provider).render)
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:dfe]
    stub_api_v2_request('/sessions', user.to_jsonapi, :post)
  end

  def stub_api_v2_request(url_path, stub, method = :get, status = 200, token: nil)
    url = "#{Settings.manage_backend.base_url}/api/v2#{url_path}"

    stubbed_request = stub_request(method, url)
                        .to_return(
                          status: status,
                          body: stub.to_json,
                          headers: { 'Content-Type': 'application/vnd.api+json' }
                        )
    if token
      stubbed_request.with(
        headers: {
          'Accept'          => 'application/vnd.api+json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'   => "Bearer #{token}",
          'Content-Type'    => 'application/vnd.api+json',
          'User-Agent'      => 'Faraday v0.15.4'
        }
      )
    end

    stubbed_request
  end
end

RSpec.configure do |config|
  config.include Helpers, type: :feature
  config.include Helpers, type: :controller
  config.include Helpers, type: :request
end
