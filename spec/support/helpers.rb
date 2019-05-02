module Helpers
  def stub_omniauth(disable_completely: true, user: nil)
    user_resource = jsonapi(:user)
    user ||= user_resource.to_resource
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:dfe] = {
      provider: "dfe",
      uid: "123456789",
      "info" => {
        "first_name" => user.first_name,
        "last_name"  => user.last_name,
        "email"      => user.email,
        'id'         => user.id,
        'state'      => user.state
      },
      credentials: {
        token_id: "123"
      }
    }

    # Temp solution until we implement `return_url` for DfE sign-in
    if disable_completely
      allow_any_instance_of(ApplicationController).to receive(:authenticate)
    end
  end

  def stub_session_create(user: double(id: 1, 'opted_in?': false))
    allow(Session).to receive(:create).and_return(user)
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
