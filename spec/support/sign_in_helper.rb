module Helpers
  def authenticate_user_steps(user: nil, provider: nil)
    stub_signed_user_steps(user: user, provider: provider)

    visit "/signin"
    click_button("Sign in using DfE Sign-in")
  end

  def signed_in_user(user: nil, provider: nil)
    user ||= build(:user)
    provider ||= build(:provider)

    stub_omniauth(user: user, provider: provider)

    authenticate_user_steps(user: user, provider: provider)
  end

private

  def stub_signed_user_steps(user: nil, provider: nil)
    stub_api_v2_request(
      "/recruitment_cycles/#{Settings.current_cycle}",
      provider.recruitment_cycle.to_jsonapi,
    )

    stub_api_v2_request(
      "/recruitment_cycles/#{Settings.current_cycle}/providers?page[page]=1",
      resource_list_to_jsonapi([provider], meta: { count: 1 }),
    )

    stub_api_v2_resource(provider)

    if user.admin
      stub_api_v2_request("/access_requests", nil)
    end
  end
end
