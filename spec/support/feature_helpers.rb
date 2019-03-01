module FeatureHelpers
  def stub_omniauth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:dfe] = {
      provider: "dfe",
      uid: "123456789",
      info: {
        first_name: "John",
        last_name: "Smith",
        email: "email@example.com"
      },
      credentials: {
        token_id: "123"
      }
    }
  end

  def stub_session_create
    allow(Session).to receive(:create).and_return(something: 'testing')
  end
end

RSpec.configure do |config|
  config.include FeatureHelpers, type: :feature
end
