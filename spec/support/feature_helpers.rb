module FeatureHelpers
  def stub_omniauth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:dfe] = {
      provider: "dfe",
      uid: "123456789",
      info: {
        first_name: "John",
        last_name: "Smith"
      },
      credentials: {
        token_id: "123"
      }
    }
  end
end

RSpec.configure do |config|
  config.include FeatureHelpers, type: :feature
end
