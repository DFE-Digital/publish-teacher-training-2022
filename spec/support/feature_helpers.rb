module FeatureHelpers
  def stub_omniauth(disable_completely: true)
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

    # Temp solution until we implement `return_url` for DfE sign-in
    if disable_completely
      allow_any_instance_of(ApplicationController).to receive(:authenticate)
    end
  end

  def stub_session_create
    allow(Session).to receive(:create).and_return(double(id: 1))
  end

  def stub_api_v2_request(url_path, fixture_file)
    url = "#{Settings.manage_backend.base_url}/api/v2#{url_path}"
    fixture_path = "spec/fixtures/#{fixture_file}"

    stub_request(:get, url)
      .to_return(
        status: 200,
        body: File.read(fixture_path),
        headers: { 'Content-Type': 'application/vnd.api+json' }
      )
  end
end

RSpec.configure do |config|
  config.include FeatureHelpers, type: :feature
end
