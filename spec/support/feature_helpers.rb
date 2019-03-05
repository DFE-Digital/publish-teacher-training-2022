module FeatureHelpers
  def stub_omniauth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:dfe] = {
      provider: "dfe",
      uid: "123456789",
      "info" => {
        "first_name" => "John",
        "last_name" => "Smith",
        "email" => "email@example.com"
      },
      credentials: {
        token_id: "123"
      }
    }
  end

  def stub_session_create
    allow(Session).to receive(:create).and_return(double(id: 1))
  end

  def stub_backend_api
    example_api_response = '{
      "data": [
        {
          "id": "4",
          "type": "providers",
          "attributes": {
            "institution_code": "A0",
            "institution_name": "ACME SCITT 0"
          },
          "relationships": {
            "courses": {
              "meta": {
                "count": 0
              }
            }
          }
        }
      ],
      "jsonapi": {
        "version": "1.0"
      }
    }'

    stub_request(:get, "#{Settings.manage_backend.base_url}/api/v2/providers")
      .to_return(
        status: 200,
        body: example_api_response,
        headers: { 'Content-Type': 'application/vnd.api+json' }
      )
  end
end

RSpec.configure do |config|
  config.include FeatureHelpers, type: :feature
end
